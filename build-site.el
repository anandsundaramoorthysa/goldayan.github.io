;; Set package installation directory
(require 'package)
(setq package-user-dir (expand-file-name "./.packages"))
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

;; Initialize the package system
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Install use-package
(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)

;; Install dependencies
(use-package htmlize
  :ensure t)

(use-package webfeeder
  :ensure t)

;; Set language environment
(set-language-environment "UTF-8")

;; Load the publishing system
(require 'ox-publish)

(defun goldayan/head-extra ()
  (concat
   "<link rel=\"shortcut icon\" href=\"/assets/logo.jpg\" type=\"image/jpeg\">"
   "<link href=\"https://fonts.cdnfonts.com/css/share-tech-mono\" rel=\"stylesheet\">"
   "<link rel=\"stylesheet\" type=\"text/css\" href=\"/assets/code.css\"/>"
   "<link rel=\"stylesheet\" type=\"text/css\" href=\"/assets/style.css\"/>")) ;; Updated for CSS-only menu

;; Define the HTML template
(defun org-html-template (contents info)
  "Custom HTML template for org-publish"
  (concat "<!DOCTYPE html>"
"<html lang=\"en\">"
  "<head>"
    "<meta charset=\"UTF-8\">"
    "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">"
    "<title>Gold Ayan's Tinker Garage</title>"
    (concat "<!-- " (org-export-data (org-export-get-date info "%Y-%m-%d") info) " -->")
    (org-html--build-meta-info info)
    (org-html--build-head info)
  "</head>"
  "<body>"

    "<header>"
      "<div class=\"container\">"
        "<h1>Gold Ayan's Tinker Garage</h1>"
      "</div>"
      "<div class=\"header-content\">"
        "<nav class=\"container\">"
          "<input type=\"checkbox\" id=\"menu-toggle\">"
          "<label for=\"menu-toggle\" class=\"hamburger\">☰</label>"
          "<ul class=\"topnav\">"
            "<li><a href=\"/index.html\">Home</a></li>"
            "<li><a href=\"/projects.html\">Projects</a></li>"
            "<li><a href=\"/posts\">Posts</a></li>"
            "<li><a href=\"/til.html\">TIL</a></li>"
            "<li><a href=\"/blogrolls.html\">Blogrolls</a></li>"
            "<li><a href=\"/feed.xml\">RSS</a></li>"
          "</ul>"
        "</nav>"
      "</div>"
    "</header>"

    "<main class=\"container\">"
      "<article class=\"blog-content\">"
      contents
      "</article>"
    "</main>"

    "<footer>"
      "This site is made with ❤️ using Emacs."
    "</footer>"

  "</body>"
"</html>"
))

;; Customize the HTML output
(setq org-html-validation-link nil
      org-html-head-include-scripts nil
      org-html-head-include-default-style nil
      org-html-htmlize-output-type 'css)

;; Define the publishing project
(setq org-publish-project-alist
      (list
       (list "goldayan:main"
             :recursive t
             :base-directory "./content"
             :base-extension "org"
             :html-head-extra (goldayan/head-extra)
             :publishing-function 'org-html-publish-to-html
             :publishing-directory "./public"
             :htmlized-source t
             :with-author nil
             :with-creator nil
             :with-toc nil
             :section-numbers nil
             :time-stamp-file nil)
       (list "goldayan:assets"
             :recursive t
             :base-directory "./assets"
             :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|html\\|mp4\\|ico"
             :publishing-function 'org-publish-attachment
             :publishing-directory "./public/assets")))

;; Generate the site output
(org-publish-all t)

(message "Build complete!")

;; RSS builder
(webfeeder-build "./feed.xml"
                 "./public"
                 "https://goldayan.in"
                 (delete "posts/index.html"
                         (let ((default-directory (expand-file-name "./public")))
                           (directory-files-recursively "posts" ".*\\.html$")))
                 :builder 'webfeeder-make-rss
                 :title "Gold Ayan's Tinker Garage"
                 :description "Let’s tinker!"
                 :author "Gold Ayan")
