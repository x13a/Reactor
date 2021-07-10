import 'package:html/dom.dart' as dom;

import 'global.dart';

class ReactorPage {
  static const postsSelector = '.postContainer';
  static const nextPageSelector = '.next';
  static const prevPageSelector = '.prev';

  final dom.Element? nextButtonElement;
  final dom.Element? prevButtonElement;
  final List<ReactorPost> posts;

  String? nextPageUrl() => nextButtonElement == null ?
    null :
    '$REACTOR_URL${nextButtonElement!.attributes["href"]}';
  String? prevPageUrl() => prevButtonElement == null ?
    null :
    '$REACTOR_URL${prevButtonElement!.attributes["href"]}';

  ReactorPage(dom.Document document) :
    nextButtonElement = document.querySelector(nextPageSelector),
    prevButtonElement = document.querySelector(prevPageSelector),
    posts = document
      .querySelectorAll(postsSelector)
      .map((value) => ReactorPost(value)).toList();
}

class ReactorPost {
  static const postContentSelector = '.post_content';

  final dom.Element post;
  final dom.Element? postContent;

  static dom.Element? fixPostGifs(dom.Element? element) {
    if (element == null) return null;
    for (var gif in element.querySelectorAll('a.video_gif_source')) {
      final href = gif.attributes['href'];
      if (href == null) continue;
      final imgDiv = gif.parent?.parent;
      if (imgDiv == null || imgDiv.className != 'image') continue;
      final img = dom.Element.tag('img');
      img.className = CLASS_NAME_POST_IMG_GIF;
      img.attributes['src'] = href;
      imgDiv.replaceWith(img);
    }
    return element;
  }

  ReactorPost(this.post) :
    postContent = fixPostGifs(post.querySelector(postContentSelector));
}
