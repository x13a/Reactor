import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';

import 'html.dart';
import 'http.dart';

class ReactorPage {
  static const postsSelector = '.postContainer';
  static const nextPageSelector = '.next';
  static const prevPageSelector = '.prev';

  final String url;
  final List<ReactorPost> posts;
  final dom.Element? nextButtonElement;
  final dom.Element? prevButtonElement;

  String? nextPageUrl() => nextButtonElement == null ?
    null :
    '$url${nextButtonElement!.attributes["href"]}';
  String? prevPageUrl() => prevButtonElement == null ?
    null :
    '$url${prevButtonElement!.attributes["href"]}';

  String toHtml() {
    return posts
      .map((e) => '<div class="post">${e.toHtml()}</div>')
      .join('<hr class="$HTML_CLASS_POSTS_SEPARATOR">\n');
  }

  ReactorPage(dom.Document document, String url) :
    this.url = Uri.parse(url).origin,
    posts = document
      .querySelectorAll(postsSelector)
      .map((e) => ReactorPost(e)).toList(),
    nextButtonElement = document.querySelector(nextPageSelector),
    prevButtonElement = document.querySelector(prevPageSelector);
}

class ReactorPost {
  static const headSelector = '.uhead';
  static const tagsSelector = '.taglist a';
  static const contentSelector = '.post_content';
  static const commentsSelector = '.post_comment_list .comment';
  static const footSelector = '.ufoot';

  final dom.Element element;
  late final ReactorHead? head;
  late final List<ReactorTag> tags;
  late ReactorPostContent? content;
  late final List<ReactorComment> bestComments;
  late final ReactorFoot? foot;

  String toHtml() {
    final content = this.content?.element.outerHtml ?? 'Not Found';
    final comments = this
      .bestComments
      .map((e) => e.content?.element.outerHtml ?? 'Not Found')
      .join('\n');
    return '<div>$content</div><div>$comments</div>';
  }

  getCensoredContent(HttpClientWithUserAgent client, String url) async {
    if (content != null ||
        element.querySelector('img[alt="Copywrite"]') == null) {
      return;
    }
    final link = foot?.getLink();
    if (link == null) return;
    final page =
      ReactorPage(parse((await client.get(Uri.parse('$url$link'))).body), url);
    content = page.posts.first.content;
  }

  ReactorPost(this.element) {
    final headElement = element.querySelector(headSelector);
    head = headElement != null ? ReactorHead(headElement) : null;
    tags = element
      .querySelectorAll(tagsSelector)
      .map((e) => ReactorTag(e))
      .toList();
    final contentElement = element.querySelector(contentSelector);
    content = contentElement != null ?
      ReactorPostContent(contentElement) :
      null;
    bestComments = element
      .querySelectorAll(commentsSelector)
      .map((e) => ReactorComment(e))
      .toList();
    final footElement = element.querySelector(footSelector);
    foot = footElement != null ? ReactorFoot(footElement) : null;
  }
}

class ReactorHead {
  final dom.Element element;

  ReactorHead(this.element);
}

class ReactorTag {
  final dom.Element element;
  late final List<int> ids;

  ReactorTag(this.element) {
    final dataIds = element.attributes['data-ids'];
    ids = dataIds == null ?
      [] :
      dataIds
        .split(',')
        .map((e) => int.parse(e))
        .toList();
  }
}

class ReactorPostContent {
  final dom.Element element;

  ReactorPostContent(this.element);
}

class ReactorComment {
  static const contentSelector = '.comment-content';

  final dom.Element element;
  late final ReactorCommentContent? content;

  ReactorComment(this.element) {
    final contentElement = element.querySelector(contentSelector);
    content = contentElement != null ?
      ReactorCommentContent(contentElement) :
      null;
  }
}

class ReactorCommentContent {
  final dom.Element element;

  ReactorCommentContent(this.element);

  getHiddenContent(HttpClientWithUserAgent client, String url) async {
    final showComment = element.querySelector('.comment_show');
    if (showComment == null) return;
    final href = showComment.attributes['href'];
    if (href == null) return;
    element.innerHtml = (await client.get(Uri.parse('$url$href'))).body;
  }
}

class ReactorFoot {
  final dom.Element element;

  String? getLink() {
    return element.querySelector('.link_wr .link')?.attributes['href'];
  }

  ReactorFoot(this.element);
}
