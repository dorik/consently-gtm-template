___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Consently CMP",
  "description": "Consently Consent Management Platform integration for Google Consent Mode v2. Enables GDPR, CCPA, and ePrivacy compliant consent collection with full IAB TCF 2.2 support.",
  "categories": [
    "TAG_MANAGEMENT",
    "PERSONALIZATION"
  ],
  "brand": {
    "id": "brand_consently",
    "displayName": "Consently",
    "thumbnail": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAACXBIWXMAAAsTAAALEwEAmpwYAAAB8ElEQVR4nO2WT0tCQRTFf2ZFRRRt2rRo06ZNmzZt+gRt2vQJ2rTpE7Rp0ydoU5s2bWrTIoiCoCCKiMg/0UKLiHDkDjzm+d68N08Lov7wwMy8e8+Zd+fODPznPysBzANbwD7wCFwBR8AqMA3EgkzgGfYEMAscAjfAI9AGnIFT4BhYBCaBQaAP6AL+CjsWOAwsA2dALXAFHAPrQBOQD+QBWUAW0A50Al3ANDABjAPDwBCQAaQBv4WZYhHfBJaBQ+AUOAfugBagHqgDaoFqoAqoBMqBUqAEKAaKgEKgAMgH8oA8IJffIDdaBXAA7ANHwDFwCtwAjUAT0Aw0AQ1APVAHVAOVQAVQDpQBpUAJUAwUAYVAAZAP5AF5QB4/IbcH7AKHwBFwApwBl0AD0AS0AK1AK9AENVANZYCVQAVUAWVAKVAOFAMFQD6QCxggF8gBsoEsIBNIBzKAdOBXkBMYAnaBfeAQOAJOgAvgEqgHGoAmoBloBpqgBmqgBiqgHCqhDEqhBEqgGIqgEAqgAMgDcoFcfkJuN9gBdoAD4BA4BE6AM+ACuATqgQagCWgGWoAWqIEaqIJyqIByKIUSKIFiKIJCKIB8yAdygVx+Qm432AZ2gAPgEDgCToBz4BK4AuqBRqAZaIFWaIU6qINKqIByKIdSKIFiKIJCKIB8yIfuBMkAAAAASUVORK5CYII="
  },
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "clientId",
    "displayName": "Client ID",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ],
    "help": "Enter your Consently Client ID. You can find this in your <a href=\"https://app.consently.net/dashboard\">Consently Dashboard</a>.",
    "valueHint": "e.g., abc123def456"
  },
  {
    "type": "SELECT",
    "name": "defaultConsent",
    "displayName": "Default consent state",
    "macrosInSelect": false,
    "selectItems": [
      {
        "value": "denied",
        "displayValue": "Denied (recommended for GDPR regions)"
      },
      {
        "value": "granted",
        "displayValue": "Granted"
      }
    ],
    "simpleValueType": true,
    "defaultValue": "denied",
    "help": "The initial consent state before user interaction. Use 'Denied' for GDPR compliance."
  },
  {
    "type": "TEXT",
    "name": "region",
    "displayName": "Region",
    "simpleValueType": true,
    "help": "Apply default consent to specific regions only. Use ISO 3166-2 codes separated by commas (e.g., DE, FR, US-CA). Leave empty to apply globally.",
    "valueHint": "e.g., DE, FR, IT"
  },
  {
    "type": "CHECKBOX",
    "name": "enableTcf",
    "checkboxText": "Enable IAB TCF 2.2 support",
    "simpleValueType": true,
    "defaultValue": true,
    "help": "When enabled, Google tags automatically read consent from the IAB TCF 2.2 TC String."
  },
  {
    "type": "TEXT",
    "name": "waitForUpdate",
    "displayName": "Wait for update (ms)",
    "simpleValueType": true,
    "defaultValue": "500",
    "valueValidators": [
      {
        "type": "POSITIVE_NUMBER"
      }
    ],
    "help": "How long Google tags wait for consent update before firing with default state. Recommended: 500ms."
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

/**
 * Consently CMP - Google Consent Mode v2 Template
 * Version: 1.0.0
 *
 * TRIGGER: Must use "Consent Initialization - All Pages"
 * DOCS: https://help.consently.net/google-consent-mode
 */

// Import required GTM Sandbox APIs
const setDefaultConsentState = require('setDefaultConsentState');
const updateConsentState = require('updateConsentState');
const gtagSet = require('gtagSet');
const injectScript = require('injectScript');
const setInWindow = require('setInWindow');
const copyFromWindow = require('copyFromWindow');
const log = require('logToConsole');
const makeNumber = require('makeNumber');
const makeString = require('makeString');
const getContainerVersion = require('getContainerVersion');

// ============================================
// CONFIGURATION
// ============================================
const clientId = data.clientId;
const defaultConsent = data.defaultConsent || 'denied';
const region = data.region || '';
const enableTcf = data.enableTcf !== false;
const waitForUpdate = makeNumber(data.waitForUpdate) || 500;

// Check if in preview/debug mode
const containerVersion = getContainerVersion();
const DEBUG = containerVersion.debugMode || containerVersion.previewMode;

// ============================================
// DEBUG LOGGING
// ============================================
const debugLog = function(message, obj) {
  if (DEBUG) {
    if (obj !== undefined) {
      log('[Consently CMP]', message, obj);
    } else {
      log('[Consently CMP]', message);
    }
  }
};

debugLog('Initializing...');

// ============================================
// LOAD ORDER DETECTION
// Checks if Google tags fired before consent was set
// ============================================
const checkLoadOrder = function() {
  const dataLayer = copyFromWindow('dataLayer');
  if (!dataLayer || !dataLayer.length) {
    return;
  }

  // Check for gtag config before this template ran
  for (var i = 0; i < dataLayer.length; i++) {
    var item = dataLayer[i];
    if (item && item[0] === 'config') {
      log('[Consently CMP] WARNING: Google tag config detected before consent initialization. Ensure this tag uses the "Consent Initialization - All Pages" trigger.');
      return;
    }
  }
};

// Run load order check in debug mode
if (DEBUG) {
  checkLoadOrder();
}

// ============================================
// STEP 1: BUILD DEFAULT CONSENT STATE
// ============================================
const defaultConsentState = {
  'ad_storage': defaultConsent,
  'ad_user_data': defaultConsent,
  'ad_personalization': defaultConsent,
  'analytics_storage': defaultConsent,
  'functionality_storage': 'granted',
  'personalization_storage': defaultConsent,
  'security_storage': 'granted',
  'wait_for_update': waitForUpdate
};

// Add region if specified
if (region && region.length > 0) {
  const regionArray = region.split(',').map(function(r) {
    return makeString(r).trim();
  }).filter(function(r) {
    return r.length > 0;
  });

  if (regionArray.length > 0) {
    defaultConsentState.region = regionArray;
  }
}

// ============================================
// STEP 2: SET DEFAULT CONSENT STATE
// ============================================
setDefaultConsentState(defaultConsentState);
debugLog('Default consent set');

// ============================================
// STEP 3: SET TCF SUPPORT
// ============================================
if (enableTcf) {
  gtagSet('gtag_enable_tcf_support', true);
}

// ============================================
// STEP 4: SET PRIVACY SAFEGUARDS
// ============================================
gtagSet('url_passthrough', true);
gtagSet('ads_data_redaction', true);

// ============================================
// STEP 5: REGISTER CONSENT CALLBACK
// CMP will call this when user makes choice
// ============================================
const consentCallback = function(consentData) {
  debugLog('Consent callback received');

  if (!consentData) {
    return;
  }

  const consentUpdate = {
    'ad_storage': consentData.ad_storage ? 'granted' : 'denied',
    'ad_user_data': consentData.ad_user_data ? 'granted' : 'denied',
    'ad_personalization': consentData.ad_personalization ? 'granted' : 'denied',
    'analytics_storage': consentData.analytics_storage ? 'granted' : 'denied',
    'functionality_storage': 'granted',
    'personalization_storage': consentData.personalization_storage ? 'granted' : 'denied',
    'security_storage': 'granted'
  };

  updateConsentState(consentUpdate);
  debugLog('Consent updated');
};

setInWindow('__consentlyCallback', consentCallback, true);

// ============================================
// STEP 6: INJECT CMP SCRIPT
// ============================================
const scriptUrl = 'https://app.consently.net/consently.js?id=' + clientId;
debugLog('Loading script:', scriptUrl);

const onSuccess = function() {
  debugLog('CMP script loaded');
  data.gtmOnSuccess();
};

const onFailure = function() {
  log('[Consently CMP] ERROR: Failed to load script:', scriptUrl);
  data.gtmOnFailure();
};

injectScript(scriptUrl, onSuccess, onFailure, 'consentlyCmp');


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "access_consent",
        "versionId": "1"
      },
      "param": [
        {
          "key": "consentTypes",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {"type": 1, "string": "consentType"},
                  {"type": 1, "string": "read"},
                  {"type": 1, "string": "write"}
                ],
                "mapValue": [
                  {"type": 1, "string": "ad_storage"},
                  {"type": 8, "boolean": true},
                  {"type": 8, "boolean": true}
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {"type": 1, "string": "consentType"},
                  {"type": 1, "string": "read"},
                  {"type": 1, "string": "write"}
                ],
                "mapValue": [
                  {"type": 1, "string": "ad_user_data"},
                  {"type": 8, "boolean": true},
                  {"type": 8, "boolean": true}
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {"type": 1, "string": "consentType"},
                  {"type": 1, "string": "read"},
                  {"type": 1, "string": "write"}
                ],
                "mapValue": [
                  {"type": 1, "string": "ad_personalization"},
                  {"type": 8, "boolean": true},
                  {"type": 8, "boolean": true}
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {"type": 1, "string": "consentType"},
                  {"type": 1, "string": "read"},
                  {"type": 1, "string": "write"}
                ],
                "mapValue": [
                  {"type": 1, "string": "analytics_storage"},
                  {"type": 8, "boolean": true},
                  {"type": 8, "boolean": true}
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {"type": 1, "string": "consentType"},
                  {"type": 1, "string": "read"},
                  {"type": 1, "string": "write"}
                ],
                "mapValue": [
                  {"type": 1, "string": "functionality_storage"},
                  {"type": 8, "boolean": true},
                  {"type": 8, "boolean": true}
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {"type": 1, "string": "consentType"},
                  {"type": 1, "string": "read"},
                  {"type": 1, "string": "write"}
                ],
                "mapValue": [
                  {"type": 1, "string": "personalization_storage"},
                  {"type": 8, "boolean": true},
                  {"type": 8, "boolean": true}
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {"type": 1, "string": "consentType"},
                  {"type": 1, "string": "read"},
                  {"type": 1, "string": "write"}
                ],
                "mapValue": [
                  {"type": 1, "string": "security_storage"},
                  {"type": 8, "boolean": true},
                  {"type": 8, "boolean": true}
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "write_data_layer",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keyPatterns",
          "value": {
            "type": 2,
            "listItem": [
              {"type": 1, "string": "gtag_enable_tcf_support"},
              {"type": 1, "string": "url_passthrough"},
              {"type": 1, "string": "ads_data_redaction"}
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "inject_script",
        "versionId": "1"
      },
      "param": [
        {
          "key": "urls",
          "value": {
            "type": 2,
            "listItem": [
              {"type": 1, "string": "https://app.consently.net/*"}
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "access_globals",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keys",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {"type": 1, "string": "key"},
                  {"type": 1, "string": "read"},
                  {"type": 1, "string": "write"},
                  {"type": 1, "string": "execute"}
                ],
                "mapValue": [
                  {"type": 1, "string": "__consentlyCallback"},
                  {"type": 8, "boolean": true},
                  {"type": 8, "boolean": true},
                  {"type": 8, "boolean": true}
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {"type": 1, "string": "key"},
                  {"type": 1, "string": "read"},
                  {"type": 1, "string": "write"},
                  {"type": 1, "string": "execute"}
                ],
                "mapValue": [
                  {"type": 1, "string": "dataLayer"},
                  {"type": 8, "boolean": true},
                  {"type": 8, "boolean": false},
                  {"type": 8, "boolean": false}
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_container_data",
        "versionId": "1"
      },
      "param": []
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: Test default consent state is set with denied
  code: |-
    const mockData = {
      clientId: 'test_123',
      defaultConsent: 'denied',
      enableTcf: true,
      waitForUpdate: 500
    };

    runCode(mockData);

    assertApi('setDefaultConsentState').wasCalled();
    assertApi('gtagSet').wasCalledWith('gtag_enable_tcf_support', true);

- name: Test default consent state with granted
  code: |-
    const mockData = {
      clientId: 'test_123',
      defaultConsent: 'granted',
      enableTcf: false,
      waitForUpdate: 300
    };

    runCode(mockData);

    assertApi('setDefaultConsentState').wasCalled();

- name: Test callback is registered
  code: |-
    const mockData = {
      clientId: 'test_123',
      defaultConsent: 'denied',
      waitForUpdate: 500
    };

    runCode(mockData);

    assertApi('setInWindow').wasCalledWith('__consentlyCallback', anyFunction, true);

- name: Test script injection success
  code: |-
    const mockData = {
      clientId: 'test_123',
      defaultConsent: 'denied',
      waitForUpdate: 500
    };

    mock('injectScript', function(url, onSuccess, onFailure, cacheToken) {
      onSuccess();
    });

    runCode(mockData);

    assertApi('gtmOnSuccess').wasCalled();

- name: Test script injection failure
  code: |-
    const mockData = {
      clientId: 'test_123',
      defaultConsent: 'denied',
      waitForUpdate: 500
    };

    mock('injectScript', function(url, onSuccess, onFailure, cacheToken) {
      onFailure();
    });

    runCode(mockData);

    assertApi('gtmOnFailure').wasCalled();

- name: Test consent callback updates state
  code: |-
    const mockData = {
      clientId: 'test_123',
      defaultConsent: 'denied',
      waitForUpdate: 500
    };

    let capturedCallback;
    mock('setInWindow', function(key, fn, overwrite) {
      if (key === '__consentlyCallback') {
        capturedCallback = fn;
      }
    });

    mock('injectScript', function(url, onSuccess, onFailure, cacheToken) {
      onSuccess();
    });

    runCode(mockData);

    // Simulate consent
    capturedCallback({
      ad_storage: true,
      ad_user_data: true,
      ad_personalization: true,
      analytics_storage: true,
      personalization_storage: false
    });

    assertApi('updateConsentState').wasCalled();

- name: Test region parsing
  code: |-
    const mockData = {
      clientId: 'test_123',
      defaultConsent: 'denied',
      region: 'DE, FR, IT',
      waitForUpdate: 500
    };

    runCode(mockData);

    assertApi('setDefaultConsentState').wasCalled();

- name: Test empty consent data handled
  code: |-
    const mockData = {
      clientId: 'test_123',
      defaultConsent: 'denied',
      waitForUpdate: 500
    };

    let capturedCallback;
    mock('setInWindow', function(key, fn, overwrite) {
      if (key === '__consentlyCallback') {
        capturedCallback = fn;
      }
    });

    mock('injectScript', function(url, onSuccess, onFailure, cacheToken) {
      onSuccess();
    });

    runCode(mockData);

    // Call with null
    capturedCallback(null);

    assertApi('updateConsentState').wasNotCalled();

- name: Test load order detection reads dataLayer
  code: |-
    const mockData = {
      clientId: 'test_123',
      defaultConsent: 'denied',
      waitForUpdate: 500
    };

    mock('getContainerVersion', function() {
      return { debugMode: true, previewMode: false };
    });

    mock('copyFromWindow', function(key) {
      if (key === 'dataLayer') {
        return [['config', 'G-XXXXXX']];
      }
      return undefined;
    });

    runCode(mockData);

    assertApi('copyFromWindow').wasCalledWith('dataLayer');
    assertApi('logToConsole').wasCalled();


___NOTES___

================================================================================
CONSENTLY CMP - GOOGLE TAG MANAGER TEMPLATE
================================================================================

Version: 1.0.0
Author: Consently (https://consently.net)
Documentation: https://help.consently.net/gtm-template
Script URL: https://app.consently.net/consently.js?id={CLIENT_ID}

TRIGGER: Must use "Consent Initialization - All Pages"

CALLBACK FORMAT (from CMP):
{
  ad_storage: boolean,
  ad_user_data: boolean,
  ad_personalization: boolean,
  analytics_storage: boolean,
  personalization_storage: boolean
}

TCF 2.2: When enabled, Google auto-infers ad consent from TC String.
analytics_storage must still be sent separately.

DEBUG MODE:
- Automatically enabled in GTM Preview mode
- Logs consent initialization and updates to console
- Detects load order issues (warns if Google tags fired before consent)

================================================================================
