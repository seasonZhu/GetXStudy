// 自动生成；请修改 lib/i18n/ 中的源词条。
const appCatalogs = {"zh":{"html.title":"网页示例","html.hello":"你好，世界！","html.call_native":"JS 调用原生","html.message":"来自 JS 的消息","html.reply":"你好，原生！","html.open":"测试按钮","html.link":"超链接跳转","html.opening":"打开链接：@url","html.failed":"好像没成功","html.flutter_message":"来自 Flutter 的消息"},"en":{"html.title":"WebView example","html.hello":"Hello, world!","html.call_native":"JS calls native","html.message":"Message from JavaScript","html.reply":"Hello, native!","html.open":"Test button","html.link":"Open link","html.opening":"Opening link: @url","html.failed":"Could not open the app","html.flutter_message":"Message from Flutter"},"fr":{"html.title":"Exemple WebView","html.hello":"Bonjour, le monde !","html.call_native":"Appel natif depuis JS","html.message":"Message de JavaScript","html.reply":"Bonjour, application !","html.open":"Bouton de test","html.link":"Ouvrir le lien","html.opening":"Ouverture du lien : @url","html.failed":"Impossible d’ouvrir l’application","html.flutter_message":"Message de Flutter"}};
let appLanguage = 'en';
window.appText = key => appCatalogs[appLanguage][key] || appCatalogs.en[key] || key;
window.setAppLanguage = language => {
  const code = language.replace('_', '-').split('-')[0];
  appLanguage = appCatalogs[code] ? code : 'en';
  document.documentElement.lang = appLanguage === 'zh' ? 'zh-CN' : appLanguage;
  document.querySelectorAll('[data-i18n]').forEach(element => {
    element.textContent = window.appText(element.dataset.i18n);
  });
};
document.addEventListener('DOMContentLoaded', () => {
  window.setAppLanguage(navigator.language || 'en');
});
