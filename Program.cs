using System;
using System.Drawing;
using System.Drawing.Drawing2D;
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
                "Gradient Screensaver\n\nColors cycle automatically every 6 seconds.\nMove mouse or click to exit.",
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
        Color.FromArgb(254, 128,  25),
        Color.FromArgb(251,  73,  52),
        Color.FromArgb(211, 134, 155),
        Color.FromArgb(184, 187,  38),
        Color.FromArgb(142, 192, 124),
        Color.FromArgb(131, 165, 152),
        Color.FromArgb( 69, 133, 136),
    };

    struct Blob
    {
        public float X, Y, Vx, Vy, R;
        public Color Current, Target;
    }

    readonly Blob[]  _blobs     = new Blob[3];
    readonly Random  _rng       = new Random();
    readonly Timer   _animTimer = new Timer();
    readonly Timer   _colorTimer = new Timer();
    Bitmap?   _buf;
    Graphics? _g;
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
        RandomizeTargets();

        _animTimer.Interval = 50;           // ~20 fps
        _animTimer.Tick    += OnTick;
        _animTimer.Start();

        _colorTimer.Interval = 6000;        // new colors every 6 s
        _colorTimer.Tick    += (_, _) => RandomizeTargets();
        _colorTimer.Start();
    }

    void InitBlobs()
    {
        float[] xs  = { .22f, .78f, .52f };
        float[] ys  = { .45f, .20f, .78f };
        float[] vxs = {  .00022f, -.00018f,  .00014f };
        float[] vys = {  .00016f,  .00021f, -.00023f };
        float[] rs  = {  .90f,  .90f,  .90f };

        for (int i = 0; i < 3; i++)
        {
            _blobs[i].X  = xs[i];  _blobs[i].Y  = ys[i];
            _blobs[i].Vx = vxs[i]; _blobs[i].Vy = vys[i];
            _blobs[i].R  = rs[i];
            _blobs[i].Current = Palette[i];
            _blobs[i].Target  = Palette[i];
        }
    }

    void RandomizeTargets()
    {
        var pool = new System.Collections.Generic.List<Color>(Palette);
        for (int i = 0; i < _blobs.Length && pool.Count > 0; i++)
        {
            int idx = _rng.Next(pool.Count);
            _blobs[i].Target = pool[idx];
            pool.RemoveAt(idx);
        }
    }

    static Color Lerp(Color a, Color b, float t) => Color.FromArgb(
        (int)(a.A + (b.A - a.A) * t),
        (int)(a.R + (b.R - a.R) * t),
        (int)(a.G + (b.G - a.G) * t),
        (int)(a.B + (b.B - a.B) * t));

    void OnTick(object? sender, EventArgs e)
    {
        for (int i = 0; i < _blobs.Length; i++)
        {
            ref var b = ref _blobs[i];
            b.X += b.Vx; b.Y += b.Vy;
            if (b.X < -.2f || b.X > 1.2f) b.Vx = -b.Vx;
            if (b.Y < -.2f || b.Y > 1.2f) b.Vy = -b.Vy;
            b.Current = Lerp(b.Current, b.Target, .025f);
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

        _g!.Clear(Color.FromArgb(28, 28, 28));

        int minDim = Math.Min(w, h);
        foreach (var b in _blobs)
            DrawBlob(b.X * w, b.Y * h, b.R * minDim, b.Current);

        e.Graphics.DrawImageUnscaled(_buf, 0, 0);
    }

    void DrawBlob(float cx, float cy, float r, Color col)
    {
        using var path  = new GraphicsPath();
        path.AddEllipse(cx - r, cy - r, r * 2, r * 2);
        using var brush = new PathGradientBrush(path) { CenterPoint = new PointF(cx, cy) };
        var blend = new ColorBlend(5);
        blend.Colors    = new[] { Color.FromArgb(0, col), Color.FromArgb(0, col), Color.FromArgb(35, col), Color.FromArgb(120, col), Color.FromArgb(175, col) };
        blend.Positions = new[] { 0f, 0.12f, 0.42f, 0.72f, 1f };
        brush.InterpolationColors = blend;
        _g!.FillPath(brush, path);
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
        _buf?.Dispose(); _g?.Dispose();
        base.OnFormClosed(e);
    }
}
