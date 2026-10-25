// App Store tanıtım görseli üretici (Fiyatmatik'teki compose.swift'in BlitzFlash uyarlaması).
// Kullanım: swift AppStoreMetadata/compose.swift <ham-klasör> <çıktı-klasör>
// Ham klasördeki simülatör görüntülerini (aşağıdaki `slides` listesi) üstte marka etiketi,
// başlık ve alt başlık bulunan, modun renginde degrade arka planlı mağaza görsellerine çevirir.
// Çıktı boyutu ham görüntüyle aynıdır, yani ASC'nin o yuva için istediği piksel boyutu.

import AppKit

struct Slide {
    let file: String
    let title: String
    let subtitle: String
    let tint: NSColor
}

func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> NSColor {
    NSColor(srgbRed: r, green: g, blue: b, alpha: 1)
}

// BlitzTheme açık mod renkleri; her görsel gösterdiği modun rengini alır.
let blue = rgb(0.15, 0.42, 0.96)
let purple = rgb(0.48, 0.32, 0.93)
let green = rgb(0.13, 0.62, 0.33)
let orange = rgb(0.95, 0.55, 0.08)

let slides: [Slide] = [
    // iPhone 6.9"
    Slide(file: "iphone69-1-ana", title: "Dört Modla Kelime Öğrenin", subtitle: "İngilizce, İspanyolca ve Çekçe", tint: blue),
    Slide(file: "iphone69-2-serbest", title: "Kartı Çevir, Kaydır, Öğren", subtitle: "889 kelime, Türkçe okunuşuyla", tint: blue),
    Slide(file: "iphone69-3-yazarak", title: "60 Saniyede Kaç Kelime?", subtitle: "Yazarak tahmin edin, puanınızı yükseltin", tint: purple),
    Slide(file: "iphone69-4-cumle", title: "Doğru Kelimeyi Bulun", subtitle: "Örnek cümlelerle bağlam içinde öğrenin", tint: green),
    Slide(file: "iphone69-5-av", title: "Kelime Avında Rekor Kırın", subtitle: "15 kart, her kelime için üç hak", tint: orange),
    // iPhone Duo
    Slide(file: "duo-ic-yatay-ana", title: "iPhone Duo'da İki Bölmeli Ekran", subtitle: "Bir yanda dil ve günlük hak, diğer yanda modlar", tint: blue),
    Slide(file: "duo-ic-dik-serbest", title: "Yarı Açıkken Rahat Okuyun", subtitle: "Kart üst yarıda, düğmeler alt yarıda", tint: blue),
    Slide(file: "duo-dis-ana", title: "Dış Ekranda Tek Bakışta", subtitle: "Günlük hakkınız kenar şeridinde", tint: blue),
    Slide(file: "duo-ic-yatay-serbest", title: "Kart Bir Yanda, Cevaplar Diğer Yanda", subtitle: "Son kartlarınız hep göz önünde", tint: blue),
    Slide(file: "duo-dis-serbest", title: "Katlıyken de Büyük Kart", subtitle: "Sayaçlar kenar şeridine taşındı", tint: blue),
    Slide(file: "duo-ic-dik-av", title: "Kelime Avı Dizüstü Gibi", subtitle: "Soru üstte, kartlar parmağınızın altında", tint: orange),
    Slide(file: "duo-ic-yatay-cumle", title: "Cümlede Doğru Kelimeyi Bulun", subtitle: "Soru bir yanda, seçenekler diğer yanda", tint: green),
    Slide(file: "duo-dis-yazarak", title: "60 Saniyede Kaç Kelime?", subtitle: "Katlıyken de yazarak tahmin", tint: purple),
]

let args = CommandLine.arguments
guard args.count == 3 else {
    print("kullanım: swift compose.swift <ham> <çıktı>")
    exit(1)
}
let rawDir = URL(fileURLWithPath: args[1])
let outDir = URL(fileURLWithPath: args[2])
try? FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)
let scriptDir = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
let logo = NSImage(contentsOf: scriptDir.appendingPathComponent("../BlitzFlash/Assets.xcassets/BlitzLogo.imageset/BlitzLogo.png"))

func roundedFont(size: CGFloat, weight: NSFont.Weight) -> NSFont {
    let base = NSFont.systemFont(ofSize: size, weight: weight)
    guard let descriptor = base.fontDescriptor.withDesign(.rounded) else { return base }
    return NSFont(descriptor: descriptor, size: size) ?? base
}

func drawCentered(_ text: String, font: NSFont, color: NSColor, centerX: CGFloat, topY: CGFloat, maxWidth: CGFloat) -> CGFloat {
    let style = NSMutableParagraphStyle()
    style.alignment = .center
    let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color, .paragraphStyle: style]
    let string = NSAttributedString(string: text, attributes: attributes)
    let bounds = string.boundingRect(with: CGSize(width: maxWidth, height: 10_000), options: [.usesLineFragmentOrigin])
    let rect = CGRect(x: centerX - maxWidth / 2, y: topY - bounds.height, width: maxWidth, height: bounds.height)
    string.draw(with: rect, options: [.usesLineFragmentOrigin])
    return bounds.height
}

for slide in slides {
    let rawURL = rawDir.appendingPathComponent(slide.file + ".png")
    guard let shot = NSImage(contentsOf: rawURL),
          let shotRep = shot.representations.first else { print("atlandı: \(slide.file)"); continue }
    let width = CGFloat(shotRep.pixelsWide), height = CGFloat(shotRep.pixelsHigh)
    let size = CGSize(width: width, height: height)
    let isLandscape = width > height
    let unit = min(width, height) / 100  // ölçek birimi

    guard let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(width), pixelsHigh: Int(height),
                                     bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                                     colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0) else { continue }
    rep.size = size
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

    // Arka plan: modun renginden koyu tonuna degrade, üstte hafif ışık
    let dark = slide.tint.blended(withFraction: 0.72, of: rgb(0.04, 0.05, 0.12)) ?? .black
    NSGradient(starting: slide.tint, ending: dark)?.draw(in: CGRect(origin: .zero, size: size), angle: -90)
    let glowCenter = CGPoint(x: width / 2, y: height)
    NSGradient(colors: [NSColor.white.withAlphaComponent(0.2), NSColor.white.withAlphaComponent(0)])?
        .draw(fromCenter: glowCenter, radius: 0, toCenter: glowCenter, radius: max(width, height) * 0.55, options: [])

    // Üst blok: logolu etiket, başlık, alt başlık (AppKit'te y aşağıdan yukarı artar)
    var cursor = height - unit * (isLandscape ? 5 : 7)
    let pillFont = roundedFont(size: unit * 2.6, weight: .heavy)
    let pillText = NSAttributedString(string: "BLITZFLASH", attributes: [.font: pillFont, .foregroundColor: rgb(0.1, 0.12, 0.22), .kern: unit * 0.3])
    let textSize = pillText.size()
    let logoSize = textSize.height * 1.35
    let pillWidth = logoSize + unit * 1.2 + textSize.width + unit * 5
    let pillHeight = logoSize + unit * 1.4
    let pillRect = CGRect(x: width / 2 - pillWidth / 2, y: cursor - pillHeight, width: pillWidth, height: pillHeight)
    NSColor.white.withAlphaComponent(0.94).setFill()
    NSBezierPath(roundedRect: pillRect, xRadius: pillHeight / 2, yRadius: pillHeight / 2).fill()
    let logoRect = CGRect(x: pillRect.minX + unit * 2, y: pillRect.midY - logoSize / 2, width: logoSize, height: logoSize)
    NSGraphicsContext.saveGraphicsState()
    NSBezierPath(roundedRect: logoRect, xRadius: logoSize * 0.23, yRadius: logoSize * 0.23).addClip()
    logo?.draw(in: logoRect)
    NSGraphicsContext.restoreGraphicsState()
    pillText.draw(at: CGPoint(x: logoRect.maxX + unit * 1.2, y: pillRect.midY - textSize.height / 2))
    cursor = pillRect.minY - unit * 3

    let textWidth = width * 0.88
    cursor -= drawCentered(slide.title, font: roundedFont(size: unit * (isLandscape ? 6 : 7.2), weight: .bold),
                           color: .white, centerX: width / 2, topY: cursor, maxWidth: textWidth)
    cursor -= unit * 1.4
    cursor -= drawCentered(slide.subtitle, font: NSFont.systemFont(ofSize: unit * (isLandscape ? 3 : 3.6), weight: .medium),
                           color: NSColor.white.withAlphaComponent(0.82), centerX: width / 2, topY: cursor, maxWidth: textWidth)
    cursor -= unit * (isLandscape ? 4 : 6)

    // Ekran görüntüsü: kalan alana sığdır, köşeleri yuvarlat, gölge ver
    let bottomMargin = unit * (isLandscape ? 4 : 6)
    let availableHeight = cursor - bottomMargin
    let availableWidth = width * (isLandscape ? 0.9 : 0.84)
    let aspect = width / height
    var shotWidth = availableWidth
    var shotHeight = shotWidth / aspect
    if shotHeight > availableHeight {
        shotHeight = availableHeight
        shotWidth = shotHeight * aspect
    }
    let shotRect = CGRect(x: width / 2 - shotWidth / 2, y: cursor - shotHeight, width: shotWidth, height: shotHeight)
    let radius = unit * (isLandscape ? 4 : 6)

    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.4)
    shadow.shadowBlurRadius = unit * 4
    shadow.shadowOffset = CGSize(width: 0, height: -unit * 1.5)
    shadow.set()
    NSColor.white.setFill()
    NSBezierPath(roundedRect: shotRect, xRadius: radius, yRadius: radius).fill()
    NSGraphicsContext.restoreGraphicsState()

    NSGraphicsContext.saveGraphicsState()
    NSBezierPath(roundedRect: shotRect, xRadius: radius, yRadius: radius).addClip()
    shot.draw(in: shotRect)
    NSGraphicsContext.restoreGraphicsState()

    NSColor.white.withAlphaComponent(0.35).setStroke()
    let border = NSBezierPath(roundedRect: shotRect.insetBy(dx: 1, dy: 1), xRadius: radius, yRadius: radius)
    border.lineWidth = max(2, unit * 0.3)
    border.stroke()

    NSGraphicsContext.restoreGraphicsState()

    // ASC alfa kanallı görseli reddedebilir: alfasız JPEG yaz.
    guard let cg = rep.cgImage,
          let ctx = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0,
                              space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else { continue }
    ctx.draw(cg, in: CGRect(origin: .zero, size: size))
    guard let flat = ctx.makeImage() else { continue }
    let outURL = outDir.appendingPathComponent("\(slide.file).jpg")
    try NSBitmapImageRep(cgImage: flat).representation(using: .jpeg, properties: [.compressionFactor: 0.92])?.write(to: outURL)
    print("\(outURL.lastPathComponent) \(Int(width))x\(Int(height))")
}
