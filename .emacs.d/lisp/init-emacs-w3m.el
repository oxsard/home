(setq w3m-coding-system 'utf-8
      w3m-file-coding-system 'utf-8
      w3m-file-name-coding-system 'utf-8
      w3m-input-coding-system 'utf-8
      w3m-output-coding-system 'utf-8
      ;; emacs-w3m will test the imagick's support for png32
      ;; and create files named "png32:-" everywhere
      w3m-imagick-convert-program nil
      w3m-terminal-coding-system 'utf-8
      w3m-use-cookies t
      w3m-cookie-accept-bad-cookies t
      w3m-home-page "http://www.google.com.au"
      w3m-command-arguments       '("-F" "-cookie")
      w3m-mailto-url-function     'compose-mail
      browse-url-browser-function 'w3m
      mm-text-html-renderer       'w3m
      w3m-use-toolbar t
      ;; show images in the browser
      ;; setq w3m-default-display-inline-images t
      ;; w3m-use-tab     nil
      w3m-confirm-leaving-secure-page nil
      w3m-search-default-engine "g"
      w3m-key-binding 'info)

(defun w3m-get-url-from-search-engine-alist (k l)
  (let (rlt)
    (if (listp l)
      (if (string= k (caar l))
          (setq rlt (nth 1 (car l)))
        (setq rlt (w3m-get-url-from-search-engine-alist k (cdr l)))))
    rlt))

;; C-u S g RET <search term> RET in w3m
(setq w3m-search-engine-alist
      '(("g" "http://www.google.com.au/search?q=%s" utf-8)
        ;; stackoverflow search
        ("q" "http://www.google.com.au/search?q=%s+site:stackoverflow.com" utf-8)
        ;; elisp code search
        ("s" "http://www.google.com.au/search?q=%s+filetype:el"  utf-8)
        ;; wikipedia
        ("w" "http://en.wikipedia.org/wiki/Special:Search?search=%s" utf-8)
        ;; online dictionary
        ("d" "http://dictionary.reference.com/search?q=%s" utf-8)
        ;; java google search
        ("java" "https://www.google.com.au/search?q=java+%s" utf-8)
        ;; financial dictionary
        ("f" "http://financial-dictionary.thefreedictionary.com/%s" utf-8)
        ;; javascript seawrch on mozilla.org
        ("j" "http://www.google.com.au/search?q=%s+site:developer.mozilla.org" utf-8)))

(defun w3m-set-url-from-search-engine-alist (k l url)
    (if (listp l)
      (if (string= k (caar l))
          (setcdr (car l) (list url))
        (w3m-set-url-from-search-engine-alist k (cdr l) url))))

(defvar w3m-global-keyword nil
  "`w3m-display-hook' must search current buffer with this keyword twice if not nil")

(defun w3m-guess-keyword ()
  (unless (featurep 'w3m) (require 'w3m))
  (w3m-url-encode-string
   (setq w3m-global-keyword
         (if (region-active-p)
             (buffer-substring-no-properties (region-beginning) (region-end))
           (read-string "Enter keyword:")))))

(defun w3m-customized-search-api (search-engine)
  (unless (featurep 'w3m) (require 'w3m))
  (w3m-search search-engine (w3m-guess-keyword)))

(defun w3m-stackoverflow-search ()
  (interactive)
  (unless (featurep 'w3m) (require 'w3m))
  (w3m-customized-search-api "q"))

(defun w3m-java-search ()
  (interactive)
  (unless (featurep 'w3m) (require 'w3m))
  (w3m-customized-search-api "java"))

(defun w3m-google-search ()
  "Google search keyword"
  (interactive)
  (unless (featurep 'w3m) (require 'w3m))
  (w3m-customized-search-api "g"))

(defun w3m-google-by-filetype ()
  "Google search 'keyword filetype:file-extension'"
  (interactive)
  (unless (featurep 'w3m) (require 'w3m))
  (let ((old-url (w3m-get-url-from-search-engine-alist "s" w3m-search-engine-alist))
        new-url)
    ;; change the url to search current file type
    (when buffer-file-name
      (setq new-url (replace-regexp-in-string
                     "filetype:.*"
                     (concat "filetype:" (file-name-extension buffer-file-name))
                     old-url))
      (w3m-set-url-from-search-engine-alist "s" w3m-search-engine-alist new-url))
    (w3m-customized-search-api "s")
    ;; restore the default url
    (w3m-set-url-from-search-engine-alist "s" w3m-search-engine-alist old-url)))

(defun w3m-search-financial-dictionary ()
  "Search financial dictionary"
  (interactive)
  (unless (featurep 'w3m) (require 'w3m))
  (w3m-customized-search-api "f"))

(defun w3m-search-js-api-mdn ()
  "Search at Mozilla Developer Network (MDN)"
  (interactive)
  (unless (featurep 'w3m) (require 'w3m))
  (w3m-customized-search-api "j"))

(defun w3m-mode-hook-setup ()
  (w3m-lnum-mode 1))

(add-hook 'w3m-mode-hook 'w3m-mode-hook-setup)

; {{ Search using external browser
(setq browse-url-generic-program
      (cond
       (*is-a-mac* "open")
       (*linux* (executable-find "firefox"))
       ))
(setq browse-url-browser-function 'browse-url-generic)

;; use external browser to search programming stuff
(defun w3mext-hacker-search ()
  "Search on all programming related sites in external browser"
  (interactive)
  (let ((keyword (w3m-guess-keyword)))
    ;; google
    (browse-url-generic (concat "http://www.google.com.au/search?hl=en&q=%22"
                                keyword
                                "%22"
                                (if buffer-file-name
									(concat "+filetype%3A" (file-name-extension buffer-file-name))
									"")))
    ;; stackoverflow.com
    (browse-url-generic (concat "http://www.google.com.au/search?hl=en&q="
                                keyword
                                "+site:stackoverflow.com" ))
    ;; koders.com
    (browse-url-generic (concat "http://code.ohloh.net/search?s=\""
                                keyword
                                "\"&browser=Default&mp=1&ml=1&me=1&md=1&filterChecked=true" ))
    ))
;; }}

(defun w3mext-open-link-or-image-or-url ()
  "Opens the current link or image or current page's uri or any url-like text under cursor in firefox."
  (interactive)
  (let (url)
    (if (or (string= major-mode "w3m-mode") (string= major-mode "gnus-article-mode"))
        (setq url (or (w3m-anchor) (w3m-image) w3m-current-url)))
    (browse-url-generic (if url url (car (browse-url-interactive-arg "URL: "))))
    ))

(eval-after-load 'w3m
  '(progn
     (define-key w3m-mode-map (kbd "C-c b") 'w3mext-open-link-or-image-or-url)
     (add-hook 'w3m-display-hook
               (lambda (url)
                 (let ((title (or w3m-current-title url)))
                   (message "url=%s title=%s w3m-current-title=%s" url title w3m-current-title)
                   (when w3m-global-keyword
                     ;; search keyword twice, first is url, second is your input,
                     ;; third is actual result
                     (goto-char (point-min))
                     (search-forward-regexp (replace-regexp-in-string " " ".*" w3m-global-keyword)  (point-max) t 3)
                     ;; move the cursor to the beginning of word
                     (backward-char (length w3m-global-keyword))
                     ;; cleanup for next search
                     (setq w3m-global-keyword nil))
                   ;; rename w3m buffer
                   (rename-buffer
                    (format "*w3m: %s*"
                            (substring title 0 (min 50 (length title)))) t))))))
(provide 'init-emacs-w3m)
