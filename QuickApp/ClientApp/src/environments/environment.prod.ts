// =============================
// Email: info@ebenmonney.com
// www.ebenmonney.com/templates
// =============================

export const environment = {
    production: true,
    baseUrl: 'https://127.0.0.1:3745', // Change this to the address of your backend API if different from frontend address
    tokenUrl: 'https://127.0.0.1:3745/connect/token', // For IdentityServer/Authorization Server API. You can set to null if same as baseUrl
    loginUrl: '/login',
    requireHttps: false
};
