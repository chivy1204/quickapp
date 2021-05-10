// =============================
// Email: info@ebenmonney.com
// www.ebenmonney.com/templates
// =============================

export const environment = {
    production: true,
    baseUrl: 'https://webapiquickapptest.eastus.cloudapp.azure.com', // Change this to the address of your backend API if different from frontend address
    tokenUrl: 'https://webapiquickapptest.eastus.cloudapp.azure.com/connect/token', // For IdentityServer/Authorization Server API. You can set to null if same as baseUrl
    loginUrl: '/login',
    requireHttps: false
};
