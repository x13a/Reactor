import 'package:html/dom.dart' as dom;

fixGifs(dom.Element? element) {
  if (element == null) return;
  for (var gif in element.querySelectorAll('a.video_gif_source')) {
    final href = gif.attributes['href'];
    if (href == null) continue;
    final imgDiv = gif.parent?.parent;
    if (imgDiv == null || imgDiv.className != 'image') continue;
    final img = dom.Element.tag('img');
    img.attributes['src'] = href;
    imgDiv.replaceWith(img);
  }
}
