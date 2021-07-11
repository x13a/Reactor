import 'package:html/dom.dart' as dom;

import 'global.dart';
import 'html.dart';
import 'http.dart';
import 'utils.dart';

class ReactorPage {
  static const postsSelector = '.postContainer';
  static const nextPageSelector = '.next';
  static const prevPageSelector = '.prev';

  final List<ReactorPost> posts;
  final dom.Element? nextButtonElement;
  final dom.Element? prevButtonElement;

  String? nextPageUrl() => nextButtonElement == null ?
    null :
    '$REACTOR_URL${nextButtonElement!.attributes["href"]}';
  String? prevPageUrl() => prevButtonElement == null ?
    null :
    '$REACTOR_URL${prevButtonElement!.attributes["href"]}';

  String toHtml() {
    return posts
      .map((e) => e.toHtml())
      .join('<hr class="$HTML_CLASS_POSTS_SEPARATOR">\n');
  }

  ReactorPage(dom.Document document) :
    posts = document
      .querySelectorAll(postsSelector)
      .map((e) => ReactorPost(e)).toList(),
    nextButtonElement = document.querySelector(nextPageSelector),
    prevButtonElement = document.querySelector(prevPageSelector);

  getCommentsHiddenContent(HttpClientWithUserAgent client) async {
    for (var commentContent in posts
      .map((e) => e.comments.map((e) => e.content))
      .expand((e) => e)
      .whereType<ReactorCommentContent>()
    ) {
      await commentContent.getHiddenContent(client);
    }
  }
}

class ReactorPost {
  static const tagsSelector = '.taglist a';
  static const contentSelector = '.post_content';
  static const commentsSelector = '.post_comment_list .comment';

  final dom.Element element;
  late final List<ReactorTag> tags;
  late final ReactorPostContent? content;
  late final List<ReactorComment> comments;

  String toHtml() {
    final content = this.content?.element.outerHtml ?? 'Not Found';
    final comments = this
      .comments
      .map((e) => e.content?.element.outerHtml)
      .join('\n');
    return '<div>$content</div><div>$comments</div>';
  }

  ReactorPost(this.element) {
    tags = element
      .querySelectorAll(tagsSelector)
      .map((e) => ReactorTag(e))
      .toList();
    final contentElement = element.querySelector(contentSelector);
    content = contentElement != null ?
      ReactorPostContent(contentElement) :
      null;
    comments = element
      .querySelectorAll(commentsSelector)
      .map((e) => ReactorComment(e))
      .toList();
  }
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

  ReactorPostContent(dom.Element element) :
    this.element = fixGifs(element);
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
  late final dom.Element element;

  ReactorCommentContent(this.element);

  getHiddenContent(HttpClientWithUserAgent client) async {
    final showComment = element.querySelector('a.comment_show');
    if (showComment == null) return;
    final href = showComment.attributes['href'];
    if (href == null) return;
    element.innerHtml = (await client.get(Uri.parse('$REACTOR_URL$href'))).body;
  }
}
