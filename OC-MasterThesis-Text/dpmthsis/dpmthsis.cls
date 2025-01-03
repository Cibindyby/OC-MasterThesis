\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{dpmthsis}[2017/07/25 DP's master's thesis class]


% TODO atbegindocument insert Front.pdf


%%% Options.


% Just pass all other options to scrbook
\DeclareOption*{%
  \PassOptionsToClass{\CurrentOption}{scrbook}%
}


% "To process the options with which the file was called, you should use:"
\ProcessOptions\relax


%%% Inherit from scrbook.


\LoadClass[%
    listof=totoc,     % list other lists (abbreviations ...) in table of contents
    numbers=noenddot, % remove dot at the end of heading number
    parskip=half,     % insert half a line spacing between paragraphs
    headsepline,      % insert separation lines for running heads
    footsepline,      % insert separation lines for running foots
    11pt,
    ]%
{scrbook}


% for unicode support ("“","”" etc.) etc.
\RequirePackage{xltxtra}


\RequirePackage{csquotes}


\RequirePackage{microtype}


\RequirePackage{libertine}
\setmonofont{inconsolata}


\RequirePackage{pdfpages}


\RequirePackage{setspace}


\RequirePackage{url}


\RequirePackage{graphicx}
\makeatletter
\g@addto@macro\@floatboxreset\centering
\makeatother


\RequirePackage{amsmath}


\RequirePackage{tikz}
\usetikzlibrary{arrows}
\tikzstyle{every picture}+=[thick]
\tikzstyle{every picture}+=[>=stealth']


\clubpenalty=10000
\widowpenalty=10000


\RequirePackage[hidelinks]{hyperref}
\renewcommand{\chapterautorefname}{Chapter}
\renewcommand{\sectionautorefname}{Section}
\renewcommand{\subsectionautorefname}{Section}
\renewcommand{\subsubsectionautorefname}{Section}


\setlength{\marginparwidth}{2cm}
\RequirePackage[textsize=small,textwidth=1.4\marginparwidth]{todonotes}
% Set proper spacing and font size for todo notes.
\makeatletter
\renewcommand{\todo}[2][]{%
  \@todo[fancyline,caption={#2}, #1]{{\scriptsize \begin{spacing}{1}#2\end{spacing}}}%
  % \@todo[caption={#2}, #1]{{\scriptsize \begin{spacing}{1}#2\end{spacing}}}%
}
\makeatother
% \RequirePackage[disable]{todonotes}


\newcommand{\src}{\todo{add src}}
\newcommand{\maybe}[1]{\todo[color=gray]{#1?}}
\newcommand{\last}[1]{\todo[color=yellow!40]{#1?}}
\newcommand{\q}[1]{\todo[color=red!40]{#1?}}
\newcommand{\dix}{\todo[color=gray]{add proof to appendix}}
\newcommand{\layout}[1]{\todo[color=yellow!40]{#1}}
\newcommand{\alert}[1]{\todo[color=red]{#1}}
\newcommand\todoin[2][]{\todo[inline, caption={2do}, #1]{
\begin{minipage}{\textwidth-4pt}#2\end{minipage}}}


\newcommand\here[0]{\noindent\rule{\textwidth}{2pt}}


% \overfullrule=2cm
