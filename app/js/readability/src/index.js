import { Readability, isProbablyReaderable } from '@mozilla/readability';
import DOMPurify from 'dompurify';

function isReaderable() {
  return isProbablyReaderable(document);
}

function parseReaderable(doc) {
  const reader = new Readability(doc);
  const article = reader.parse();
  return article;
}

function applyReaderable() {
  const clonedDoc = document.cloneNode(true);
  const article = parseReaderable(clonedDoc);
  const markup = DOMPurify.sanitize(article.content);

  // console.log('article title: ', parsed.title);
  // console.log('HTML string of processed article content: ', parsed.content);
  // console.log('text content of the article, with all the HTML tags removed: ', parsed.textContent);
  // console.log('length of an article, in characters: ', parsed.length);
  // console.log('article description, or short excerpt from the content: ', parsed.excerpt);
  // console.log('author metadata: ', parsed.byline);
  // console.log('content direction: ', parsed.dir);
  // console.log('name of the site: ', parsed.siteName);
  // console.log('content language: ', parsed.lang);
  // console.log('published time: ', parsed.publishedTime);

  if (markup) {
    document.body.innerHTML = '<div style="margin: 4pt;">' + markup + '</div>';
  }
}

// Attach functions to the window object
window.isReaderable = isReaderable;
window.applyReaderable = applyReaderable;

export { isReaderable, applyReaderable };
