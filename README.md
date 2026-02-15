# Consently CMP - Google Tag Manager Template

Google Tag Manager template for [Consently](https://consently.net) Consent Management Platform with Google Consent Mode v2 and IAB TCF 2.2 support.

## Features

- **Google Consent Mode v2** - All 7 consent signals supported
- **IAB TCF 2.2** - Automatic consent inference from TC String
- **Region targeting** - Apply default consent to specific regions
- **Privacy safeguards** - URL passthrough and ads data redaction

## Installation

1. In Google Tag Manager, go to **Templates** > **Tag Templates** > **Search Gallery**
2. Search for "Consently CMP"
3. Click **Add to workspace**
4. Create a new tag using the Consently CMP template
5. Enter your Client ID from [Consently Dashboard](https://app.consently.net)
6. Set trigger to **Consent Initialization - All Pages**

## Configuration

| Field                 | Description                                                  |
| --------------------- | ------------------------------------------------------------ |
| Client ID             | Your Consently Client ID                                     |
| Default consent state | Initial consent before user interaction (Denied recommended) |
| Region                | ISO 3166-2 codes for region-specific consent                 |
| Enable IAB TCF 2.2    | Enable TC String support for Google tags                     |
| Wait for update       | Time to wait for user consent (default: 500ms)               |

## Trigger

This tag **must** use the **Consent Initialization - All Pages** trigger to ensure consent is set before any other tags fire.

## Support

- [Help Center](https://help.consently.net)
- [GitHub Issues](https://github.com/nicholasoxford/consently-gtm-template/issues)

## License

Apache 2.0 - See [LICENSE](LICENSE)
