## Regular Expression 筆記

1.  GooglePlay Android Application 頁面

    ```bash
    https://play.google.com/store/recommended?sp=CAEwAA%3D%3D:S:ANO1ljJWlbk&c=apps&hl=zh-TW
    目的：將該頁面中所有的 Application 的 id 爬出來 (該頁面以 g.html 為檔名存擋)

    $ grep -Po '(?<=\?id=)[^"]*' g.html |sort|uniq|grep -P "\."|grep -v "\+"
    am.sunrise.android.calendar
    com.alfred.parkinglot
    com.apple.android.music
    com.asus.livewallpaper.asusdayscene
    com.balysv.loop
    com.bbs.reader
    com.djages.taipeifoodblogs
    com.ea.game.simcitymobile_row
    com.esri.arcgis.android.idt.EPA.HL
    ...
    ```

2.  \b 探討

    ```python
    依 [python 2.7.13] 手冊定義：

        Matches the empty string, but only at the beginning or end of a word.

        \b 在 word 之前或之後都是空白時，pattern 是 match 的。

        例如：
        >>> bool(re.search(r'\ba\b', ' a '))
        True


        A word is defined as a sequence of alphanumeric or underscore characters,
        so the end of a word is indicated by
        whitespace or a
        non-alphanumeric,
        non-underscore character.

        講述 word 的定義
        定義是，為一連串字母數字或有底線字母所組成，一個字之尾通常其後會有
        空白、非字母數字或非底線字母。


        Note that formally,
        \b is defined as the boundary between a \w and a \W character (or vice versa),
        or between \w and the beginning/end of the string,
        so the precise set of characters deemed to be alphanumeric
        depends on the values of the UNICODE and LOCALE flags.

        通常，\b 指的是 \w 及 \W 之間的界線。
        \w 為 any alphanumeric character and the underscore，即字母數字或是有底線字母
        \W 為 any non-alphanumeric character，即非字母數字

        或，在 \w 與 string 之開頭/結束之間的界線。
        例如：有一字串 "A word is defined as a sequence of alphanumeric or underscore characters"
        在此字串中，所有空白皆是 \w 間的界線。


        For example, r'\bfoo\b' matches 'foo', 'foo.', '(foo)', 'bar foo baz'
        but not 'foobar' or 'foo3'. Inside a character range,
        \b represents the backspace character,
        for compatibility with Python’s string literals.

        此處，我們使用 python re 模組做實驗：
        re 模組中，我們挑選 search 這個方法。

    search 定義:
        Scan through string looking for the first location
        where the regular expression pattern produces a match,
        and return a corresponding MatchObject instance.

        Return None if no position in the string matches the pattern;
        note that this is different from finding a zero-length match
        at some point in the string.

        找出 string 中第一個符合正規表示式 pattern 的地方，
        若成功找到，則回傳一個 MatchObject instance。

    依據上面範例，測試結果皆無問題。
    然而，發現一特殊情況：

    >>> bool(re.search(r'\bfoo\b', '(foo)'))
    True

    若將 pattern 改成 r'\bfoo\b$'，則結果為

    >>> bool(re.search(r'\bfoo\b$', '(foo)'))
    False

    經多次實驗後，發現 pattern 若修正為 r'\bfoo\b\W&' 則結果為

    >>> bool(re.search(r'\bfoo\b\W$', '(foo)'))
    True

    若在 pattern 中用 ^，情況也相同

    >>> bool(re.search(r'^\bfoo\b', '(foo)'))
    False

    >>> bool(re.search(r'^\W\bfoo\b', '(foo)')
    True

    至於為何要加 \W 進 pattern 才會 match，則有待進一步研究。
    ```

[python 2.7.13]:https://docs.python.org/2/library/re.html
