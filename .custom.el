(require 'ox-latex)
(setq org-latex-pdf-process
      '("xelatex -interaction nonstopmode %f"
        "xelatex -interaction nonstopmode %f"))
(add-to-list 'org-latex-classes
             '("cn-art"
               "\\documentclass{ctexart}"))


(load "auctex.el" nil t t)
(load "preview-latex.el" nil t t)

(mapc (lambda (mode)
        (add-hook 'LaTeX-mode-hook mode))
      (list 'auto-fill-mode
            'LaTeX-math-mode
            'turn-on-reftex
            'linum-mode))

(add-hook 'LaTeX-mode-hook
          (lambda ()
            (setq TeX-auto-untabify t
                  TeX-engine 'xetex
                  TeX-show-compilation t)
            (TeX-global-PDF-mode t)
            (setq TeX-save-query nil)
            (imenu-add-menubar-index)
            (define-key LaTeX-mode-map
              (kbd "TAB")
              'TeX-complete-symbol)))

(setq TeX-view-program-list
      '(("zathura" "zathura %o")))

(setq TeX-view-program-list
      '(("zathura" "zathura %o")
        ("Gsview" "gsview32.exe %o")
        ("Okular" "okular --unique %o")
        ("Evince" "evince %o")
        ("Firefox" "firefox %o")))

(add-hook 'LaTeX-mode-hook
          (lambda ()
            (setq TeX-view-program-selection '((output-pdf "zathura")))))

;;;
;sddsdsada
