local ls = require 'luasnip'
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local fmt = require('luasnip.extras.fmt').fmt
local fmta = require('luasnip.extras.fmt').fmta
local rep = require('luasnip.extras').rep

return {
  -- Document structure
  s(
    { trig = 'template', name = 'LaTeX Document Template' },
    fmta(
      [[
      \documentclass{<>}
      \usepackage[utf8]{inputenc}
      \usepackage{amsmath, amssymb}
      \usepackage{graphicx}
      \usepackage{hyperref}

      \title{<>}
      \author{<>}
      \date{<>}

      \begin{document}

      \maketitle

      <>

      \end{document}
      ]],
      {
        c(1, { t 'article', t 'report', t 'book', t 'beamer' }),
        i(2, 'Title'),
        i(3, 'Author'),
        c(4, { t '\\today', i(1, 'Date') }),
        i(0),
      }
    )
  ),

  -- Environments
  s(
    { trig = 'beg', name = 'Begin/End Environment' },
    fmta(
      [[
      \begin{<>}
        <>
      \end{<>}
      ]],
      { i(1, 'environment'), i(0), rep(1) }
    )
  ),

  s(
    { trig = 'enum', name = 'Enumerate' },
    fmta(
      [[
      \begin{enumerate}
        \item <>
      \end{enumerate}
      ]],
      { i(0) }
    )
  ),

  s(
    { trig = 'item', name = 'Itemize' },
    fmta(
      [[
      \begin{itemize}
        \item <>
      \end{itemize}
      ]],
      { i(0) }
    )
  ),

  s(
    { trig = 'desc', name = 'Description' },
    fmta(
      [[
      \begin{description}
        \item[<>] <>
      \end{description}
      ]],
      { i(1, 'label'), i(0) }
    )
  ),

  -- Figures
  s(
    { trig = 'fig', name = 'Figure' },
    fmta(
      [[
      \begin{figure}[<>]
        \centering
        \includegraphics[width=<>\textwidth]{<>}
        \caption{<>}
        \label{fig:<>}
      \end{figure}
      ]],
      {
        c(1, { t 'htbp', t 'H', t 'h', t 't', t 'b', t 'p' }),
        i(2, '0.8'),
        i(3, 'image.png'),
        i(4, 'caption'),
        i(5, 'label'),
      }
    )
  ),

  s(
    { trig = 'subfig', name = 'Subfigure' },
    fmta(
      [[
      \begin{figure}[<>]
        \centering
        \begin{subfigure}[b]{<>\textwidth}
          \centering
          \includegraphics[width=\textwidth]{<>}
          \caption{<>}
          \label{fig:<>}
        \end{subfigure}
        \hfill
        \begin{subfigure}[b]{<>\textwidth}
          \centering
          \includegraphics[width=\textwidth]{<>}
          \caption{<>}
          \label{fig:<>}
        \end{subfigure}
        \caption{<>}
        \label{fig:<>}
      \end{figure}
      ]],
      {
        c(1, { t 'htbp', t 'H' }),
        i(2, '0.45'),
        i(3, 'image1.png'),
        i(4, 'caption1'),
        i(5, 'label1'),
        rep(2),
        i(6, 'image2.png'),
        i(7, 'caption2'),
        i(8, 'label2'),
        i(9, 'main caption'),
        i(0, 'main-label'),
      }
    )
  ),

  -- Tables
  s(
    { trig = 'table', name = 'Table' },
    fmta(
      [[
      \begin{table}[<>]
        \centering
        \caption{<>}
        \label{tab:<>}
        \begin{tabular}{<>}
          \hline
          <> \\
          \hline
          <> \\
          \hline
        \end{tabular}
      \end{table}
      ]],
      {
        c(1, { t 'htbp', t 'H' }),
        i(2, 'caption'),
        i(3, 'label'),
        i(4, 'l|c|r'),
        i(5, 'header'),
        i(0, 'content'),
      }
    )
  ),

  -- Math environments
  s(
    { trig = 'eq', name = 'Equation' },
    fmta(
      [[
      \begin{equation}
        \label{eq:<>}
        <>
      \end{equation}
      ]],
      { i(1, 'label'), i(0) }
    )
  ),

  s(
    { trig = 'align', name = 'Align' },
    fmta(
      [[
      \begin{align}
        <> &= <> \\
        &= <>
      \end{align}
      ]],
      { i(1), i(2), i(0) }
    )
  ),

  s({ trig = 'mk', name = 'Inline Math' }, fmta([[$<>$]], { i(0) })),

  s({ trig = 'dm', name = 'Display Math' }, fmta([[\[<>\]]], { i(0) })),

  -- Fractions and symbols
  s({ trig = '/', name = 'Fraction', wordTrig = false }, fmta([[\frac{<>}{<>}]], { i(1), i(0) })),

  s({ trig = 'sq', name = 'Square Root' }, fmta([[\sqrt{<>}]], { i(0) })),

  s({ trig = 'sum', name = 'Summation' }, fmta([[\sum_{<>}^{<>} <>]], { i(1, 'i=1'), i(2, 'n'), i(0) })),

  s({ trig = 'int', name = 'Integral' }, fmta([[\int_{<>}^{<>} <> \,d<>]], { i(1, 'a'), i(2, 'b'), i(3), i(0, 'x') })),

  s({ trig = 'lim', name = 'Limit' }, fmta([[\lim_{<> \to <>} <>]], { i(1, 'x'), i(2, '\\infty'), i(0) })),

  s({ trig = 'prod', name = 'Product' }, fmta([[\prod_{<>}^{<>} <>]], { i(1, 'i=1'), i(2, 'n'), i(0) })),

  -- Derivatives
  s({ trig = 'dd', name = 'Derivative' }, fmta([[\frac{d<>}{d<>}]], { i(1, 'y'), i(0, 'x') })),

  s({ trig = 'pd', name = 'Partial Derivative' }, fmta([[\frac{\partial <>}{\partial <>}]], { i(1, 'f'), i(0, 'x') })),

  -- Matrices
  s(
    { trig = 'mat', name = 'Matrix' },
    fmta(
      [[
      \begin{<>matrix}
        <>
      \end{<>matrix}
      ]],
      { c(1, { t '', t 'p', t 'b', t 'B', t 'v', t 'V' }), i(0), rep(1) }
    )
  ),

  -- Greek letters (common ones)
  s({ trig = '@a', wordTrig = false }, t '\\alpha'),
  s({ trig = '@b', wordTrig = false }, t '\\beta'),
  s({ trig = '@g', wordTrig = false }, t '\\gamma'),
  s({ trig = '@d', wordTrig = false }, t '\\delta'),
  s({ trig = '@e', wordTrig = false }, t '\\epsilon'),
  s({ trig = '@z', wordTrig = false }, t '\\zeta'),
  s({ trig = '@h', wordTrig = false }, t '\\eta'),
  s({ trig = '@t', wordTrig = false }, t '\\theta'),
  s({ trig = '@l', wordTrig = false }, t '\\lambda'),
  s({ trig = '@m', wordTrig = false }, t '\\mu'),
  s({ trig = '@p', wordTrig = false }, t '\\pi'),
  s({ trig = '@r', wordTrig = false }, t '\\rho'),
  s({ trig = '@s', wordTrig = false }, t '\\sigma'),
  s({ trig = '@o', wordTrig = false }, t '\\omega'),

  -- Sections
  s({ trig = 'sec', name = 'Section' }, fmta([[\section{<>}]], { i(0) })),
  s({ trig = 'ssec', name = 'Subsection' }, fmta([[\subsection{<>}]], { i(0) })),
  s({ trig = 'sssec', name = 'Subsubsection' }, fmta([[\subsubsection{<>}]], { i(0) })),

  -- Text formatting
  s({ trig = 'tt', name = 'Texttt' }, fmta([[\texttt{<>}]], { i(0) })),
  s({ trig = 'bf', name = 'Textbf' }, fmta([[\textbf{<>}]], { i(0) })),
  s({ trig = 'it', name = 'Textit' }, fmta([[\textit{<>}]], { i(0) })),
  s({ trig = 'em', name = 'Emph' }, fmta([[\emph{<>}]], { i(0) })),

  -- Citations and references
  s({ trig = 'cite', name = 'Cite' }, fmta([[\cite{<>}]], { i(0) })),
  s({ trig = 'ref', name = 'Reference' }, fmta([[\ref{<>}]], { i(0) })),
  s({ trig = 'eqref', name = 'Equation Reference' }, fmta([[\eqref{<>}]], { i(0) })),

  -- Code listings
  s(
    { trig = 'code', name = 'Code Listing' },
    fmta(
      [[
      \begin{lstlisting}[language=<>, caption={<>}, label={lst:<>}]
      <>
      \end{lstlisting}
      ]],
      { i(1, 'Python'), i(2, 'caption'), i(3, 'label'), i(0) }
    )
  ),
}
