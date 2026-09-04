<p align="center">
  <img width="250" src="apps/weblibre/assets/icon/icon.png" alt="WebLibre logo">
</p>

# WebLibre

<p align="center"><strong>A privacy-focused Android browser with powerful browsing separation, local-first tools, and deep customization.</strong></p>

<p align="center">
  <a href="https://github.com/FaFre/WebLibre/releases">
    <img alt="Latest GitHub release" src="https://img.shields.io/github/v/release/FaFre/WebLibre">
  </a>
  <a href="https://f-droid.org/en/packages/eu.weblibre.gecko/">
    <img alt="F-Droid version" src="https://img.shields.io/f-droid/v/eu.weblibre.gecko">
  </a>
  <a href="COPYING">
    <img alt="License: AGPL-3.0" src="https://img.shields.io/badge/license-AGPL--3.0-blue">
  </a>
  <a href="https://liberapay.com/FaFre/donate">
    <img alt="Liberapay patrons" src="https://img.shields.io/liberapay/patrons/FaFre">
  </a>
</p>

WebLibre is an independent browser for Android devices, built on [Mozilla's Gecko engine](https://wiki.mozilla.org/Gecko) and [Mozilla Android Components](https://mozac.org/). It combines strong privacy defaults with containers, isolated tabs, built-in Tor and proxy routing, Firefox-compatible extensions, on-device search, and flexible tab management.

WebLibre is not a Firefox fork. It is its own browser experience, designed for people who want familiar everyday browsing without giving up control over how sites, identities, and network connections are separated.

**Coming from Firefox for Android, Fennec, or IronFox?** Websites and extensions behave the same because WebLibre uses the same Gecko engine. On top of that, WebLibre adds features that Firefox and its hardened forks do not offer: isolated tabs, containers with per-container cookie isolation and Tor/proxy routing, a built-in multi-protocol proxy client, tree-style tab management, and on-device local search across tabs, history, and feeds.

> [!IMPORTANT]
> **Early Access** - WebLibre is under active development. Many people already use it every day, but features and settings can change. Some updates may cause problems or change how features work.

## Install WebLibre

WebLibre requires Android 8.0 or newer. Android 13 or newer is recommended. On Android 12 and older, you may see visual problems.

<p align="center">
  <a href="https://github.com/FaFre/WebLibre/releases">
    <img height="90" alt="Get WebLibre from GitHub" src="https://docs.weblibre.eu/weblibre/_images/badges/github.png">
  </a>
  <a href="https://f-droid.org/en/packages/eu.weblibre.gecko/">
    <img height="90" alt="Get WebLibre on F-Droid" src="https://docs.weblibre.eu/weblibre/_images/badges/fdroid.png">
  </a>
  <a href="https://play.google.com/store/apps/details?id=eu.weblibre.gecko">
    <img height="90" alt="Get WebLibre on Google Play" src="https://docs.weblibre.eu/weblibre/_images/badges/google_play.png">
  </a>
</p>

- **[GitHub Releases](https://github.com/FaFre/WebLibre/releases)** - Direct downloads; [Obtainium](https://obtainium.imranr.dev/) can manage updates. Most current devices use the `arm64-v8a` APK; `armeabi-v7a` is for older 32-bit devices, and `x86_64` is for emulators, ChromeOS and x86 tablets.
- **[Google Play](https://play.google.com/store/apps/details?id=eu.weblibre.gecko)** - Automatic updates through Google Play.
- **[F-Droid](https://f-droid.org/en/packages/eu.weblibre.gecko/)** - F-Droid creates and signs its own builds. New versions may arrive considerably later than on GitHub or Google Play because of the complex build process and manual review by the F-Droid team.

> [!WARNING]
> You cannot switch directly between an F-Droid build and a GitHub or Google Play build because they use different signing keys - you must uninstall the current build first, which deletes your data.
>
> Before you uninstall, create an encrypted [profile backup](https://docs.weblibre.eu/weblibre/profiles.html#_back_up_a_profile). Use **Change Backup Directory** to save the backup outside WebLibre's app storage, then verify the backup.

### Verify your download

You can verify that an APK is an official build with `apksigner verify --print-certs`. The SHA-256 certificate fingerprints are:

- **GitHub Releases / Google Play:**

  ```text
  8F:52:6E:1E:53:D6:BD:4D:FB:F4:F4:B9:3C:2A:91:EC:B5:CB:8D:A5:E1:4A:D9:4C:25:70:E1:E3:C7:13:52:7F
  ```

- **F-Droid** (signed by F-Droid with their own key):

  ```text
  BB:2A:97:F5:61:53:35:C9:E5:7C:86:6F:1C:30:ED:4F:D7:D7:BD:DC:BC:BC:06:68:FE:93:A5:79:17:3D:3D:2D
  ```

## Start Here

On first launch, choose the setup that fits you:

- **Quick Start** applies the recommended defaults and installs uBlock Origin automatically.
- **Custom Setup** lets you choose search, DNS over HTTPS, layout, hardening, on-device AI, and extension options.
- **Restore from Backup** imports an existing encrypted WebLibre profile before setup.

After installation, these guides provide the fastest introduction:

- **[First Launch Guide](https://docs.weblibre.eu/weblibre/getting-started.html)** - Understand what each first-launch option (Quick Start, Custom Setup, Restore from Backup) does.
- **[Privacy Check-Up](https://docs.weblibre.eu/weblibre/quick-start.html)** - Review the most important privacy settings after setup.
- **[Switching from Another Browser](https://docs.weblibre.eu/weblibre/migration.html)** - Move bookmarks and browsing habits in stages.
- **[Common Workflows](https://docs.weblibre.eu/weblibre/workflows.html)** - Learn everyday tasks and power-user flows.

## What Makes WebLibre Different

### Privacy controls that you can tune

New installations start with strict tracking protection. WebLibre also includes DNS over HTTPS, HTTPS-only protection, removal of tracking information from URLs, Global Privacy Control, fingerprinting defenses, site isolation, an Intent Gatekeeper for links opened by other apps, and optional screenshot protection.

You can change each privacy setting. Stronger protection can break some websites, so you can add an exception for a site or use a less strict mode.

**Learn more:** [Privacy overview](https://docs.weblibre.eu/weblibre/privacy/overview.html) | [Threat model](https://docs.weblibre.eu/weblibre/threat-model.html)

### Tabs, containers, and profiles

- Open **Regular**, **Private**, or **Isolated** tabs. Each isolated tab has a separate session from every other tab. Unlike private tabs, isolated tabs remain open after you quit and reopen WebLibre.
- Organize tabs in list, grid, or tree views, with parent-child relationships, stacking, filtering, pinning, bulk actions, and a quick switcher.
- Use **Containers** for different activities and assign sites to them automatically.
- Enable **Cookie Isolation** on a container to give it separate cookies, logins, and site data, then optionally add clear-on-exit rules or per-container Tor/proxy routing.
- Create separate **Profiles** for independent tabs, bookmarks, history, logins, extensions, feeds, and settings. Profiles can be backed up and protected using compatible Android device authentication.

**Learn more:** [Tab management](https://docs.weblibre.eu/weblibre/tabs/tab-management.html) | [Containers](https://docs.weblibre.eu/weblibre/tabs/containers.html) | [Profiles](https://docs.weblibre.eu/weblibre/profiles.html)

### Built-in Tor and proxy routing

WebLibre includes Tor without requiring a separate Tor app. Route regular browsing, private tabs, or selected cookie-isolated containers through Tor, with bridge options such as obfs4 and Snowflake when needed.

The built-in proxy client supports SOCKS, HTTP, WireGuard, Shadowsocks, and [a dozen more protocols](https://docs.weblibre.eu/weblibre/proxy.html). Connections can be created manually or imported from subscriptions, QR codes, WireGuard files, and sing-box JSON.

**Learn more:** [Tor integration](https://docs.weblibre.eu/weblibre/tor.html) | [Proxy connections](https://docs.weblibre.eu/weblibre/proxy.html)

### Firefox-compatible extensions

Install uBlock Origin during onboarding, discover add-ons in WebLibre's in-app store, use a custom collection, or install a local `.xpi` file. Installed extensions can be updated, configured, and pinned to the toolbar from inside the browser.

Not every desktop Firefox extension works well on Android. Add-ons that depend on desktop-only interfaces may be limited, and unsigned extensions should only be installed from sources you trust.

**Learn more:** [Extensions](https://docs.weblibre.eu/weblibre/extensions.html)

### Search locally before searching the web

The address bar can search open tabs, bookmarks, saved feed articles, history, and popular sites before sending a query to a web provider. The local search index can also index the text of pages you visit on your device, with controls for private tabs, individual containers, and index deletion.

Bang providers and custom search engines let you send a query directly to a specific website. Local results stay on your device. If web autocomplete is enabled, partial text is sent to your selected suggestion provider; submitting a web search sends the full query to your selected search engine.

**Learn more:** [Personal Local Search](https://docs.weblibre.eu/weblibre/search/local-search.html) | [Bang providers](https://docs.weblibre.eu/weblibre/search/bangs.html)

### Reading and organization tools

- **On-Device AI** can suggest draft containers and names from open tab titles. It is optional, requires confirmation before changing anything, and may download a model to your phone.
- **Page Translation** translates supported languages on-device after any required language-model download.
- **Reader Mode**, PDF/Markdown/full-page export, a QR scanner, and installable web apps are built in.
- **RSS/Atom feeds** and Small Web discovery help you follow and find independent sites.
- **Firefox Sync** can synchronize tabs, bookmarks, and history with your other devices.

**Learn more:** [On-Device AI](https://docs.weblibre.eu/weblibre/on-device-ai.html) | [Content tools](https://docs.weblibre.eu/weblibre/reader-mode.html) | [Full documentation](https://docs.weblibre.eu/)

## Documentation and Community

Full user documentation is available at **[docs.weblibre.eu](https://docs.weblibre.eu/)**.

- **[Troubleshooting](https://docs.weblibre.eu/weblibre/troubleshooting.html)** - Fix common problems and learn what to include in a bug report.
- **[Feedback Platform](https://feedback.weblibre.eu/)** - Suggest and vote on features.
- **[Matrix Chat](https://matrix.to/#/#weblibre:unredacted.org)** - Ask questions and talk with the community.
- **[GitHub Issues](https://github.com/FaFre/WebLibre/issues)** - Report reproducible bugs and follow development.

## Support the Project

- **[WebLibre Supporter](https://docs.weblibre.eu/weblibre/supporter-subscription.html)** - Fund development and get access to WebLibre Search and encrypted sync for WebLibre settings. The browser and its built-in privacy controls remain free.
- **[GitHub Sponsors](https://github.com/sponsors/FaFre)** - Sponsor development through GitHub.
- **[Liberapay](https://liberapay.com/FaFre/donate)** - Make a recurring donation.
- **[Ko-fi](https://ko-fi.com/FaFre)** - Make a one-time donation.

<p align="center">
  <a href="https://liberapay.com/FaFre/donate"><img alt="Donate with Liberapay" src="https://docs.weblibre.eu/weblibre/_images/badges/liberapay.svg"></a>
  <a href="https://ko-fi.com/FaFre"><img alt="Donate with Ko-fi" src="https://docs.weblibre.eu/weblibre/_images/badges/kofi.svg"></a>
  <a href="https://github.com/sponsors/FaFre"><img alt="Donate with GitHub Sponsors" src="https://docs.weblibre.eu/weblibre/_images/badges/github_sponsors.svg"></a>
  <a href="#monero"><img alt="Donate with Monero" src="https://docs.weblibre.eu/weblibre/_images/badges/monero.svg"></a>
  <a href="#litecoin"><img alt="Donate with Litecoin" src="https://docs.weblibre.eu/weblibre/_images/badges/litecoin.svg"></a>
</p>

### Monero

```text
89rpdkq1XJYJYUshjF23YZhJdNEpghrQTXnz7vxnrLVHGrrqXTZ6BdKbqgyQnNZCkxTDA4RfhDsUcF6eHAAqco4WDQR2cZF
```

### Litecoin

```text
ltc1q0dtutc9zgkvffevwsz7s87379puk37hwn4un94
```

## License

WebLibre is free software licensed under the [GNU Affero General Public License v3.0](COPYING).
