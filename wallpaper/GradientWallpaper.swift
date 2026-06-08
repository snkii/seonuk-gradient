import AppKit
import WebKit
import CoreGraphics

let html = """
<!DOCTYPE html><html><head><meta charset="UTF-8">
<style>*{margin:0;padding:0}html,body{width:100%;height:100%;overflow:hidden;background:#1c1c1c}canvas{display:block}</style>
</head><body><canvas id="c"></canvas><script>
const c = document.getElementById('c');
const ctx = c.getContext('2d');
function resize(){ c.width = window.innerWidth; c.height = window.innerHeight; }
window.addEventListener('resize', resize); resize();

const palette = [
  [250,189,47],[254,128,25],[251,73,52],[211,134,155],
  [184,187,38],[142,192,124],[131,165,152],[69,133,136]
];

const blobs = [
  {x:.22,y:.45,vx:.00022,vy:.00016,r:.70,c:[250,189,47], t:[250,189,47]},
  {x:.78,y:.20,vx:-.00018,vy:.00021,r:.65,c:[131,165,152],t:[131,165,152]},
  {x:.52,y:.78,vx:.00014,vy:-.00023,r:.60,c:[211,134,155],t:[211,134,155]},
];

function lerp(a,b,t){ return a.map((v,i)=>v+(b[i]-v)*t); }

function randomize(){
  const pool=[...palette].sort(()=>Math.random()-.5);
  blobs.forEach((b,i)=>{ b.t=[...pool[i]]; });
}
randomize();
setInterval(randomize, 6000);

function draw(){
  const w=c.width, h=c.height, m=Math.min(w,h);
  ctx.fillStyle='rgb(28,28,28)';
  ctx.fillRect(0,0,w,h);
  for(const b of blobs){
    b.c=lerp(b.c,b.t,.025);
    b.x+=b.vx; b.y+=b.vy;
    if(b.x<-.2||b.x>1.2) b.vx*=-1;
    if(b.y<-.2||b.y>1.2) b.vy*=-1;
    const cx=b.x*w, cy=b.y*h, r=b.r*m;
    const [r_,g_,bl_]=b.c.map(Math.round);
    const g=ctx.createRadialGradient(cx,cy,0,cx,cy,r);
    g.addColorStop(0,   `rgba(${r_},${g_},${bl_},.52)`);
    g.addColorStop(.45, `rgba(${r_},${g_},${bl_},.22)`);
    g.addColorStop(.75, `rgba(${r_},${g_},${bl_},.06)`);
    g.addColorStop(1,   `rgba(${r_},${g_},${bl_},0)`);
    ctx.fillStyle=g; ctx.fillRect(0,0,w,h);
  }
  requestAnimationFrame(draw);
}
draw();
</script></body></html>
"""

class WallpaperDelegate: NSObject, NSApplicationDelegate {
    var windows: [NSWindow] = []

    func applicationDidFinishLaunching(_ n: Notification) {
        NSScreen.screens.forEach { windows.append(makeWindow($0)) }
    }

    func makeWindow(_ screen: NSScreen) -> NSWindow {
        let win = NSWindow(
            contentRect: screen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false,
            screen: screen
        )
        win.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)))
        win.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        win.isOpaque = true
        win.hasShadow = false
        win.ignoresMouseEvents = true
        win.setFrame(screen.frame, display: true)

        let wv = WKWebView(frame: CGRect(origin: .zero, size: screen.frame.size))
        wv.setValue(false, forKey: "drawsBackground")
        win.contentView = wv
        wv.loadHTMLString(html, baseURL: nil)

        win.orderFrontRegardless()
        return win
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.prohibited)
let delegate = WallpaperDelegate()
app.delegate = delegate
app.run()
