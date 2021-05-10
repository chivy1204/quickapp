// =============================
// Email: info@ebenmonney.com
// www.ebenmonney.com/templates
// =============================

// This file can be replaced during build by using the `fileReplacements` array.
// `ng build --prod` replaces `environment.ts` with `environment.prod.ts`.
// The list of file replacements can be found in `angular.json`.

export const environment = {
    production: true,
    baseUrl: 'https://webapiquickapptest.eastus.cloudapp.azure.com', // Change this to the address of your backend API if different from frontend address
    tokenUrl: 'https://webapiquickapptest.eastus.cloudapp.azure.com/connect/token', // For IdentityServer/Authorization Server API. You can set to null if same as baseUrl
    loginUrl: '/login',
    requireHttps: false
};

/*
 * For easier debugging in development mode, you can import the following file
 * to ignore zone related error stack frames such as `zone.run`, `zoneDelegate.invokeTask`.
 *
 * This import should be commented out in production mode because it will have a negative impact
 * on performance if an error is thrown.
 */
// import 'zone.js/dist/zone-error';  // Included with Angular CLI.
