// 用于String替换掉Html元素的分类
extension Extension on String {
  String get replaceHtmlElement {
    return replaceAll(RegExp("(<em[^>]*>)|(</em>)"), "")
        // 先处理 HTML 标签
        .replaceAll("<p>", "")
        .replaceAll("</p>", "")
        .replaceAll("</br>", "\n")
        .replaceAll("<br>", "\n")
        // 先处理 &amp;（让其他实体先解码）
        .replaceAll("&amp;", "&")
        // 然后处理其他 HTML 实体
        .replaceAll("&lt;", "<")
        .replaceAll("&gt;", ">")
        .replaceAll("&nbsp;", " ")
        .replaceAll("&quot;", "\"")
        .replaceAll("&yen;", "¥")
        .replaceAll("&ndash;", "–")
        .replaceAll("&mdash;", "—")
        .replaceAll("&lsquo;", "\u2018")
        .replaceAll("&rsquo;", "\u2019")
        .replaceAll("&sbquo;", "\u201A")
        .replaceAll("&ldquo;", "\u201C")
        .replaceAll("&rdquo;", "\u201D")
        .replaceAll("&bdquo;", "\u201E")
        .replaceAll("&permil;", "‰")
        .replaceAll("&lsaquo;", "‹")
        .replaceAll("&rsaquo;", "›")
        .replaceAll("&euro;", "€")
        // 先处理连续换行，再处理连续空格
        .replaceAll(RegExp(r"\n{2,}"), "\n")
        .replaceAll(RegExp(r"[ \t]{2,}"), " ");
  }
}