import 'page.dart';

const HTML_CONTENT = '%CONTENT%';
const HTML_CSS_COLOR = '%COLOR%';
const HTML_CSS_BACKGROUND = '%BACKGROUND%';
const HTML_CLASS_POST = 'post';
const HTML_CLASS_POSTS_SEPARATOR = 'posts-separator';
const HTML_JS_SHOW_COMMENT_CHANNEL = 'ShowComment';
const HTML_JS_MESSAGE_SEPARATOR = ';';

const REACTOR_HTML = """
  <!DOCTYPE html>
  <html lang="ru">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
      :root {
        --iframe-default-height: 56.25vw;
      }
      
      body {
        color: $HTML_CSS_COLOR;
        background: $HTML_CSS_BACKGROUND;
      }
      
      img, video {
        width: 100%;
        height: auto;
        object-fit: cover;
        object-position: 0 10px;
      }
      
      a {
        color: inherit;
      }
      
      iframe {
        --size-extra: 10px;
        width: calc(100vw - var(--size-extra));
        height: calc(var(--iframe-default-height) - var(--size-extra));
      }
      
      ${ReactorComment.contentSelector} iframe {
        --size-extra: 25px;
        width: calc(100vw - var(--size-extra));
        height: calc(var(--iframe-default-height) - var(--size-extra));
      }
      
      .video_gif_source {
        display: none;
      }
      
      hr.$HTML_CLASS_POSTS_SEPARATOR {
        margin: 10px 0;
      }
      
      ${ReactorPost.contentSelector} {
        max-height: 2000px;
        overflow: hidden;
      }
      
      ${ReactorComment.contentSelector} {
        border: 1px solid;
        margin: 5px 0;
        padding: 5px;
      }
    </style>
    <script>
      (function() {
      
        function fixCoubs() {
          const posts = document.querySelectorAll('.$HTML_CLASS_POST');
          for (let post of posts) {
            const content = post
              .querySelector('${ReactorPost.contentSelector}');
            if (content === null) {
              continue;
            }
            const iframes = content.querySelectorAll('iframe');
            if (iframes.length !== 1 || content.querySelector('img') !== null) {
              continue;
            }
            const coub = iframes[0];
            if (!coub.src.startsWith('https://coub.com')) {
              continue;
            }
            const json = post
              .querySelector('${ReactorPost.ldJsonSelector}');
            if (json === null) {
              continue;
            }
            const image = JSON.parse(json.innerHTML)['image'];
            if (image === null) {
              continue;
            }
            const width = image['width'];
            const height = image['height'];
            if (width === null || height === null) {
              continue;
            }
            coub
              .style
              .setProperty(
                'height', 
                'calc((100vw * %d) - 10px)'.replace('%d', height / width));
          }
        }
        
        function addShowCommentHandlers() {
          const comments = document
            .querySelectorAll('${ReactorCommentContent.showSelector}');
          for (let comment of comments) {
            comment.onclick = function() {
              const msg = this.parentElement.id + 
                '$HTML_JS_MESSAGE_SEPARATOR' + 
                this.href;
              $HTML_JS_SHOW_COMMENT_CHANNEL.postMessage(msg);
            }
          }
        }
      
        document.addEventListener('DOMContentLoaded', function() {
          fixCoubs();
          addShowCommentHandlers();
        });

      })();
    </script>
  </head>
  <body>
    <div>
      $HTML_CONTENT
    </div>
  </body>
  </html>
""";
