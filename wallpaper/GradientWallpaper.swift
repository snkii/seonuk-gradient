import AppKit
import WebKit
import CoreGraphics

let html = """
<!DOCTYPE html><html><head><meta charset="UTF-8">
<style>*{margin:0;padding:0}html,body{width:100%;height:100%;overflow:hidden;background:#282828}</style>
</head><body><script>
const palette = [
  [250,189,47],[254,128,25],[251,73,52],[211,134,155],
  [184,187,38],[142,192,124],[131,165,152],[69,133,136]
];

const blobs = [
  {x:.22,y:.45,vx:.00022,vy:.00016,r:.90,c:[250,189,47],t:[250,189,47],el:null},
  {x:.78,y:.20,vx:-.00018,vy:.00021,r:.90,c:[131,165,152],t:[131,165,152],el:null},
  {x:.52,y:.78,vx:.00014,vy:-.00023,r:.90,c:[211,134,155],t:[211,134,155],el:null},
];

blobs.forEach(b => {
  const el = document.createElement('div');
  el.style.position = 'fixed';
  el.style.borderRadius = '50%';
  el.style.opacity = '0.7';
  el.style.willChange = 'transform, background-color';
  document.body.appendChild(el);
  b.el = el;
  const m = Math.min(window.innerWidth, window.innerHeight);
  const size = b.r * m;
  el.style.width = el.style.height = size + 'px';
  el.style.filter = `blur(${Math.round(m * 0.22)}px)`;
});

function lerp(a,b,t){ return a.map((v,i)=>v+(b[i]-v)*t); }

function randomize(){
  const pool=[...palette].sort(()=>Math.random()-.5);
  blobs.forEach((b,i)=>{ b.t=[...pool[i]]; });
}
randomize();
setInterval(randomize, 6000);

function draw(){
  const w=window.innerWidth, h=window.innerHeight, m=Math.min(w,h);
  for(const b of blobs){
    b.c=lerp(b.c,b.t,.025);
    b.x+=b.vx; b.y+=b.vy;
    if(b.x<-.2||b.x>1.2) b.vx*=-1;
    if(b.y<-.2||b.y>1.2) b.vy*=-1;
    const size=b.r*m;
    const [r_,g_,bl_]=b.c.map(Math.round);
    b.el.style.background = `rgb(${r_},${g_},${bl_})`;
    b.el.style.transform = `translate(${b.x*w - size/2}px, ${b.y*h - size/2}px)`;
  }
  requestAnimationFrame(draw);
}
draw();
</script></body></html>
"""

class WallpaperDelegate: NSObject, NSApplicationDelegate {
    var windows: [NSWindow] = []
    var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ n: Notification) {
        NSScreen.screens.forEach { windows.append(makeWindow($0)) }
        setupMenuBar()
    }

    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "sparkles", accessibilityDescription: "Gradient Wallpaper")
        }
        let menu = NSMenu()
        let header = NSMenuItem(title: "Gradient Wallpaper", action: nil, keyEquivalent: "")
        header.isEnabled = false
        menu.addItem(header)
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem?.menu = menu
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
app.setActivationPolicy(.accessory)
let delegate = WallpaperDelegate()
app.delegate = delegate
app.run()
