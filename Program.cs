using System;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.Windows.Forms;

namespace GradientScreenSaver;

static class Program
{
    [STAThread]
    static void Main(string[] args)
    {
        Application.EnableVisualStyles();
        Application.SetCompatibleTextRenderingDefault(false);

        string mode = args.Length > 0 ? args[0].ToLower().TrimStart('/') : "s";

        if (mode == "c")
        {
            MessageBox.Show(
                "Gradient Screensaver\n\nColors cycle automatically every 7 seconds.\nMove mouse or click to exit.",
                "Gradient Screensaver", MessageBoxButtons.OK, MessageBoxIcon.Information);
        }
        else if (mode.StartsWith("p"))
        {
            // preview mode: skip
        }
        else
        {
            foreach (Screen screen in Screen.AllScreens)
                new ScreenSaverForm(screen.Bounds).Show();
            Application.Run();
        }
    }
}

class ScreenSaverForm : Form
{
    static readonly Color[] Palette =
    {
        Color.FromArgb(250, 189,  47),
        Color.FromArgb(215, 153,  33),
        Color.FromArgb(254, 128,  25),
        Color.FromArgb(251,  73,  52),
        Color.FromArgb(184, 187,  38),
        Color.FromArgb(142, 192, 124),
        Color.FromArgb(131, 165, 152),
        Color.FromArgb( 69, 133, 136),
        Color.FromArgb(211, 134, 155),
        Color.FromArgb(146, 131, 116),
    };

    const float BlobSizeFactor = .90f;
    const float BlurFactor = .22f;
    const float ColorTransitionSeconds = 6.5f;
    const int FineGrainTileSize = 96;
    const int CoarseGrainTileSize = 360;
    const int FineGrainAlpha = 11;
    const int CoarseGrainAlpha = 5;

    struct Blob
    {
        public float X, Y, Vx, Vy, Vr, R, Sx, Sy, Rot, ColorElapsed;
        public Color Current, Start, Target;
    }

    readonly Blob[]  _blobs     = new Blob[3];
    readonly Random  _rng       = new Random();
    readonly Timer   _animTimer = new Timer();
    readonly Timer   _colorTimer = new Timer();
    readonly Stopwatch _clock = Stopwatch.StartNew();
    Bitmap?   _buf;
    Bitmap?   _fineGrainTile;
    Bitmap?   _coarseGrainTile;
    TextureBrush? _fineGrainBrush;
    TextureBrush? _coarseGrainBrush;
    Graphics? _g;
    double     _lastTickSeconds;
    Point     _lastMouse;
    bool      _firstMove = true;

    public ScreenSaverForm(Rectangle bounds)
    {
        SetStyle(ControlStyles.AllPaintingInWmPaint | ControlStyles.UserPaint | ControlStyles.OptimizedDoubleBuffer, true);
        Bounds          = bounds;
        FormBorderStyle = FormBorderStyle.None;
        TopMost         = true;
        BackColor       = Color.Black;
        Cursor.Hide();

        InitBlobs();

        _lastTickSeconds = _clock.Elapsed.TotalSeconds;

        _animTimer.Interval = 66;           // homepage mesh cadence
        _animTimer.Tick    += OnTick;
        _animTimer.Start();

        _colorTimer.Interval = 7000;        // new colors every 7 s
        _colorTimer.Tick    += (_, _) => RandomizeTargets();
        _colorTimer.Start();
    }

    void InitBlobs()
    {
        for (int i = 0; i < 3; i++)
        {
            var color = RandomColor();
            var velocity = RandomVelocity();
            _blobs[i] = new Blob
            {
                X = NextFloat(-.12f, 1.12f),
                Y = NextFloat(-.10f, 1.10f),
                Vx = velocity.vx,
                Vy = velocity.vy,
                Vr = NextFloat(-.8f, .8f),
                R = NextFloat(.86f, 1.08f),
                Sx = NextFloat(.85f, 1.38f),
                Sy = NextFloat(.78f, 1.28f),
                Rot = NextFloat(0f, 360f),
                Current = color,
                Start = color,
                Target = color,
                ColorElapsed = ColorTransitionSeconds,
            };
        }
    }

    void RandomizeTargets()
    {
        for (int i = 0; i < _blobs.Length; i++)
        {
            _blobs[i].Start = _blobs[i].Current;
            _blobs[i].Target = RandomColor();
            _blobs[i].ColorElapsed = 0f;
        }
    }

    Color RandomColor() => Palette[_rng.Next(Palette.Length)];

    float NextFloat(float min, float max) => min + (float)_rng.NextDouble() * (max - min);

    (float vx, float vy) RandomVelocity()
    {
        float angle = NextFloat(0f, MathF.PI * 2f);
        float speed = NextFloat(.0026f, .0054f);
        return (MathF.Cos(angle) * speed, MathF.Sin(angle) * speed);
    }

    static float EaseInOut(float t)
    {
        t = Math.Clamp(t, 0f, 1f);
        return t * t * (3f - 2f * t);
    }

    static Color Lerp(Color a, Color b, float t) => Color.FromArgb(
        (int)(a.A + (b.A - a.A) * t),
        (int)(a.R + (b.R - a.R) * t),
        (int)(a.G + (b.G - a.G) * t),
        (int)(a.B + (b.B - a.B) * t));

    void OnTick(object? sender, EventArgs e)
    {
        double now = _clock.Elapsed.TotalSeconds;
        float dt = (float)Math.Min(now - _lastTickSeconds, .25);
        _lastTickSeconds = now;

        for (int i = 0; i < _blobs.Length; i++)
        {
            ref var b = ref _blobs[i];
            b.X += b.Vx * dt; b.Y += b.Vy * dt;
            b.Rot += b.Vr * dt;
            if (b.X < -.2f || b.X > 1.2f) b.Vx = -b.Vx;
            if (b.Y < -.2f || b.Y > 1.2f) b.Vy = -b.Vy;
            if (b.ColorElapsed < ColorTransitionSeconds)
            {
                b.ColorElapsed += dt;
                b.Current = Lerp(b.Start, b.Target, EaseInOut(b.ColorElapsed / ColorTransitionSeconds));
            }
        }
        Invalidate();
    }

    protected override void OnPaint(PaintEventArgs e)
    {
        int w = Width, h = Height;

        if (_buf == null || _buf.Width != w || _buf.Height != h)
        {
            _buf?.Dispose(); _g?.Dispose();
            _buf = new Bitmap(w, h);
            _g   = Graphics.FromImage(_buf);
            _g.SmoothingMode    = SmoothingMode.AntiAlias;
            _g.CompositingMode  = CompositingMode.SourceOver;
        }

        _g!.Clear(Color.FromArgb(40, 40, 40));

        int minDim = Math.Min(w, h);
        foreach (var b in _blobs)
        {
            float size = b.R * BlobSizeFactor * minDim;
            DrawBlob(b.X * w, b.Y * h, size, BlurFactor * minDim, b.Sx, b.Sy, b.Rot, b.Current);
        }
        ApplyFilmTexture(w, h);

        e.Graphics.DrawImageUnscaled(_buf, 0, 0);
    }

    void ApplyFilmTexture(int width, int height)
    {
        ApplyFilmTone(width, height);
        ApplyFilmGrain(width, height);
    }

    void ApplyFilmTone(int width, int height)
    {
        using var linear = new LinearGradientBrush(
            new Rectangle(0, 0, Math.Max(width, 1), Math.Max(height, 1)),
            Color.FromArgb(16, 251, 73, 52),
            Color.FromArgb(14, 69, 133, 136),
            135f);
        linear.InterpolationColors = new ColorBlend
        {
            Colors = new[]
            {
                Color.FromArgb(16, 251, 73, 52),
                Color.FromArgb(7, 184, 187, 38),
                Color.FromArgb(14, 69, 133, 136),
            },
            Positions = new[] { 0f, .45f, 1f }
        };
        _g!.FillRectangle(linear, 0, 0, width, height);

        using var path = new GraphicsPath();
        path.AddEllipse(width * -.25f, height * -.35f, width * 1.4f, height * 1.4f);
        using var radial = new PathGradientBrush(path)
        {
            CenterPoint = new PointF(width * .48f, height * .42f),
            CenterColor = Color.FromArgb(19, 250, 189, 47),
            SurroundColors = new[] { Color.FromArgb(0, 40, 40, 40) }
        };
        _g.FillPath(radial, path);
    }

    void ApplyFilmGrain(int width, int height)
    {
        if (_fineGrainBrush == null)
        {
            _fineGrainTile = CreateGrainTile(FineGrainTileSize, FineGrainAlpha, 0x5E0A);
            _fineGrainBrush = new TextureBrush(_fineGrainTile, WrapMode.Tile);
        }
        if (_coarseGrainBrush == null)
        {
            _coarseGrainTile = CreateGrainTile(CoarseGrainTileSize, CoarseGrainAlpha, 0xC0A4);
            _coarseGrainBrush = new TextureBrush(_coarseGrainTile, WrapMode.Tile);
        }

        _g!.FillRectangle(_coarseGrainBrush, 0, 0, width, height);
        _g.FillRectangle(_fineGrainBrush, 0, 0, width, height);
    }

    static Bitmap CreateGrainTile(int size, int alpha, int seed)
    {
        var bmp = new Bitmap(size, size, PixelFormat.Format32bppPArgb);
        var rng = new Random(seed);

        for (int y = 0; y < size; y++)
        for (int x = 0; x < size; x++)
        {
            bool light = rng.Next(2) == 0;
            int value = light ? 255 : 0;
            bmp.SetPixel(x, y, Color.FromArgb(alpha, value, value, value));
        }

        return bmp;
    }

    void DrawBlob(float cx, float cy, float size, float blur, float sx, float sy, float rot, Color col)
    {
        float r = size / 2f + blur * 2f;
        var state = _g!.Save();
        _g.TranslateTransform(cx, cy);
        _g.RotateTransform(rot);
        _g.ScaleTransform(sx, sy);

        using var path  = new GraphicsPath();
        path.AddEllipse(-r, -r, r * 2, r * 2);
        using var brush = new PathGradientBrush(path) { CenterPoint = PointF.Empty };
        var blend = new ColorBlend(5);
        blend.Colors    = new[] { Color.FromArgb(0, col), Color.FromArgb(18, col), Color.FromArgb(66, col), Color.FromArgb(132, col), Color.FromArgb(178, col) };
        blend.Positions = new[] { 0f, .26f, .56f, .82f, 1f };
        brush.InterpolationColors = blend;
        _g.FillPath(brush, path);
        _g.Restore(state);
    }

    protected override void OnMouseMove(MouseEventArgs e)
    {
        if (_firstMove) { _lastMouse = e.Location; _firstMove = false; return; }
        if (Math.Abs(e.X - _lastMouse.X) > 10 || Math.Abs(e.Y - _lastMouse.Y) > 10)
            Application.Exit();
    }

    protected override void OnMouseDown(MouseEventArgs e) => Application.Exit();
    protected override void OnKeyDown(KeyEventArgs e)     => Application.Exit();

    protected override void OnFormClosed(FormClosedEventArgs e)
    {
        _animTimer.Dispose(); _colorTimer.Dispose();
        _fineGrainBrush?.Dispose(); _fineGrainTile?.Dispose();
        _coarseGrainBrush?.Dispose(); _coarseGrainTile?.Dispose();
        _buf?.Dispose(); _g?.Dispose();
        base.OnFormClosed(e);
    }
}
