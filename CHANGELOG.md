## 0.30.0
### GeckoView 155.0

This release brings together eleven updates since the last stable version. It gives you more control over when links open in other apps, adds website notifications without needing Google, makes bookmarks and the home screen far more customizable, and improves how WebLibre connects through Tor and proxies.

## Highlights

- **App Links** — decide when links open in other apps, with rules per site and per container
- **Website Notifications** — get notified by websites via UnifiedPush, without Google's involvement
- **Bookmarks Rewritten** — large bookmark collections load fast, and imports run smoothly in the background
- **Redesigned Home Page** — customize your sections, add a wallpaper, and choose where the search bar sits
- **Clearer Connections** — see at a glance how each tab is connecting, with more reliable Tor/proxy startup
- **Bangs Overhaul** — pin your favorite search shortcuts and use them right from the address bar
- **Customizable Browser Menu** — reorder or hide the menu items you don't use
- **Settings Export & Import** — copy your settings to another device in a few taps
- **Engine Upgrade** — GeckoView 155.0 for better compatibility and security

## App Links (New)

The web is full of links that could open in another app — a YouTube link opening the YouTube app, for example. WebLibre now lets you decide what happens when a page tries to do that.

- **Three modes** under Settings > Browsing > Open Links in Apps: **Ask before opening** (default), **Always**, and **Never**.
- **Remember your choice for a site** — tap "Remember for this site" in a prompt, and revisit or undo any saved choices later from a "Remembered site rules" list.
- **Per-site override** in a site's settings: always open in app, always keep in browser, or follow your default.
- **Advanced: per-container rules** — containers with their own cookies can have their own App Links setting and remembered sites, separate from the rest of the app. Handy if you want a Shopping container to always stay in-browser while a Media container opens YouTube freely.
- **Less disruptive prompts** — a small banner asks about ordinary links so you can keep reading while you decide; links with nothing to show get a simple pop-up instead. Only one shows at a time, and they no longer get stuck on screen or vanish on their own before you've had a chance to answer.
- **Closing a prompt without choosing now genuinely does nothing** — it won't be treated as "No", and it won't be remembered as a permanent choice, like it sometimes was before.
- **New setting: Wait for your answer** — turn this on if you'd rather the page not start loading until after you've answered the prompt (normally it keeps loading behind the scenes while you decide).
- **"Sign in with" flows now work properly** — many sites let you sign in by bouncing you to another app and back (like "Sign in with Google"). This now works correctly even if you've set links to Never open other apps. A new **Allow login app callbacks** setting (on by default) lets you turn this back off.
- **Extra care for your privacy** — while browsing privately, through Tor or a proxy, or in a strict container, WebLibre never opens another app on its own — you're always asked, and it won't offer to remember your answer, so an anonymous session can't be linked back to you through another app. A few sensitive link types (like ones for payment apps, or links embedded in a page's own code) always require an explicit tap from you and can never open an app silently, and a remembered choice will never open a different app than the one you originally picked.
- This is different from the existing **Intent Gatekeeper** setting, which controls whether *other* apps are allowed to send links *into* WebLibre.
- Fixed some pages endlessly reloading themselves when they tried (and failed) to open an app you don't have installed.

## Website Notifications (New)

Websites can now send you notifications — even when WebLibre isn't open — without going through Google.

- Moved out of Experimental into its own **Notifications** settings screen.
- Built on **UnifiedPush**, an open, Google-independent alternative to Firebase Cloud Messaging. Instead of routing through Google, you choose a delivery app you trust (such as ntfy, which you can even self-host) the first time you turn this on.
- The Notifications screen shows whether everything is set up correctly, and lists which sites currently have notifications turned on.
- Nothing is on by default: a site has to ask you for permission, and you need to have chosen a delivery app and granted Android's notification permission.
- Notifications are delivered reliably, even if your connection drops for a moment, and can still arrive while the app is fully closed.
- Your choice of delivery app and your subscriptions are kept separate for each profile.
- To stop notifications from a specific site, turn off notifications for that site (from its site info panel) rather than looking for an "unsubscribe" button in the Notifications screen.

## Bookmarks

- **Folders open instantly**, even with a huge bookmark collection — WebLibre no longer tries to load your entire bookmark tree at once.
- **Importing a large bookmarks file no longer freezes the app** — you'll see a progress screen while it works in the background, and it finishes much faster than before.
- **Safer imports** — an empty or broken bookmarks file can no longer accidentally wipe out your existing bookmarks. Re-importing a Firefox export also rebuilds your Toolbar, Menu, and Unfiled folders more faithfully.
- **More ways to organize your list** — sort by title, web address, or date; show folders only; hide empty built-in folders; collapse everything with one tap. Your choices are remembered.
- **New setting: what happens when you tap a bookmark** — always ask (default, unchanged), open in a regular tab, a private tab, a Custom Tab, or an isolated tab.
- **Better folder tools** — add bookmarks straight into the folder you're viewing, move folders safely, merge a folder into its parent, and see how many bookmarks are inside before you delete a folder.

## Redesigned Home Page

- Closing your last tab (or opening the app) now shows a proper home screen: a search bar at the top with voice and QR-scan buttons, and a scrollable list of sections below it — Quick Actions, Shortcuts, Recent Tabs, a daily Quote, and more.
- **Customize your home screen** — reorder sections, show or hide the ones you don't use, and reset to the defaults if you change your mind. The home page and the new-tab page can look different from each other.
- **New setting: what to show when there's no tab open** — the home page (default), your last tab, or a specific address you choose, with an option to apply this per container too.
- **Better shortcuts** — add one by hand by typing a title and address, hide every shortcut from one website at once, and removed shortcuts now actually stay removed instead of quietly coming back.
- **Choose where the search bar sits** — follow your tab bar (default), pin it to the top of the home page, or use the tab bar's own address field instead.
- **Home screen wallpapers** — pick a photo, with controls for blur and dimming so your text stays readable, and set a different wallpaper per container if you like.
- The home screen now centers itself nicely when you only have a few sections turned on, and the daily quote has a cleaner look with an easy refresh button.

## Clearer Connections (Proxy & Tor)

WebLibre's proxy support is built on **sing-box**, the same open-source proxy engine it has used since the last release, supporting protocols like Shadowsocks, VMess, VLESS, Trojan, and WireGuard.

- **Redesigned Connections screen** — each tab now shows exactly how it's connecting ("This tab: Tor", "This tab: Direct connection", or "Blocked — start your connection first", with a one-tap button to start it). One screen lets you choose the connection for regular tabs, private tabs, an isolated tab, or a whole container.
- Each saved connection now shows what's using it, and ones nothing is using are hidden to keep the list tidy.
- **Start Automatically** — flag any proxy or Tor connection to start as soon as you open WebLibre, so it's ready before you need it.
- Isolated tabs can now use their own connection, separate from their container.
- **Stronger privacy by default** — WebLibre never sends your traffic over an unprotected connection by mistake. If a tab is supposed to use a proxy that isn't running, its traffic (and related background activity like search suggestions or site icons) is blocked rather than silently sent unprotected.
- Fixed proxies occasionally failing to start with a "connection already in use" type error.
- **More reliable when opening links from other apps** — a proxied link opened via a Custom Tab, a home-screen shortcut, or an installed web app now works correctly the first time, even if WebLibre wasn't already running; before, this could sometimes load nothing at all.
- These same proxied launches now show a clear "Connecting privately…" message while your connection starts, with options to try again, open normally, or cancel — instead of failing silently or opening unprotected.
- Websites you visit are now kept more strongly separated from each other for better privacy, and WebLibre uses a little less memory while sitting idle.
- **New Proxy Logs screen** for troubleshooting — filter by severity, copy or share what you're viewing, and adjust how much detail is logged.
- Importing WireGuard connections is easier and comes tuned with mobile-friendly defaults.

## DNS over HTTPS

- Custom DNS-over-HTTPS providers you add are now saved in a list next to the built-in ones (up to 16), so switching between them is a single tap instead of retyping the address every time. Deleting the one you're using safely falls back to the default so lookups never stop working.

## History & Link Cleaning

- **"Exclude from History" now works for every container**, not just ones with their own separate cookies.
- Turning on "Exclude from History" also removes that container's pages from your on-device search results.
- Excluding a container's history is now more reliable, including for pop-ups and tabs opened from links — and if WebLibre is ever unsure, it plays it safe and doesn't record a visit.
- **You can now restore a removed tracking parameter** from a cleaned-up link, if there's one you actually want to keep (like a referral code).
- The tracking indicator now clearly shows whether a link is fully cleaned, partially cleaned, or untouched, and no longer gets stuck showing the wrong status.

## Tabs, Gestures & Navigation

- Swiping between tabs (or using a next/previous tab gesture) now follows the order you actually see on screen — including any sorting or grouping you've set up — and can move across containers instead of stopping at the edge of one.
- **New actions** you can assign to a gesture or the toolbar: open the home screen, hide/show the tab bar, switch to the next or previous container, and open the container list.
- **New two-finger gestures in the tab overview**: swipe with two fingers to switch containers, or pinch to switch between tab layouts.
- **New setting: what happens when a tab opens in the background** — stay where you are with a "Switch" button (default), or jump to the new tab right away.
- **New setting: swiping past your last tab** — move into the next container (default), or loop back to your first tab.
- **New setting: show the tab close button** on the active tab only, on every tab, or not at all.
- Closing a tab now more reliably takes you back to the tab that opened it, even across containers.
- Fixed reordering tabs sometimes sending a tab flying to the top or bottom of the list by accident.
- Fixed long-pressing a tab sometimes starting a drag instead of opening its menu (or the other way around).
- Long-pressing a tab group now opens a proper menu — new tab, pin, close, bookmark, clear data, edit, delete — instead of jumping straight into the group editor.
- Fixed tabs occasionally getting stuck showing an outdated title, icon, or address, most noticeable after restoring several tabs at once.
- **Mouse and trackpad support** — scrolling now correctly affects whatever menu or panel is open, instead of the page underneath it, and you can resize or dismiss panels with the scroll wheel too.
- Pull-to-refresh no longer triggers by accident after zooming in or out, or while watching a fullscreen video or playing a fullscreen game. Three-finger taps (like the screenshot gesture on some phones) no longer scroll the page or close tabs by accident.

## Search & Bangs

Bangs are shortcuts like `!g` that jump straight to a specific search engine.

- **Type a bang directly in the address bar** — like `!g cats` or `cats !g` — and watch the search icon update as you type.
- **Pin your favorite bangs** to keep them close at hand, and long-press one to pin, unpin, edit, or turn it into your own custom shortcut.
- **New setting: Popular Site Suggestions** — turn off suggested well-known websites when nothing in your own history matches what you're typing.

## Browser Menu & Toolbar

- **Customize the browser menu** — reorder or hide the sections and buttons you don't use, with an option to reset to the default layout. Find it via "Customize menu" at the bottom of the menu, or in Settings.
- The QR-code scanner and voice search can now be added to your toolbar, so they're available while browsing a page, not just from the home screen.

## Settings Export & Import (New)

- Export your settings to a file (or the clipboard) and import them on another device — handy when setting up a new phone.
- Choose to transfer just your app settings, advanced browser preferences, or both.
- This isn't a full backup: it doesn't include your tabs, history, bookmarks, saved logins, or account sign-in. Sensitive details like passwords are scrubbed where possible, but it's worth reviewing an exported file before sharing it.

## Backup, Restore & Profiles

- Backing up or restoring a profile now closes and reopens the app to do it safely, with clear messages explaining what's happening at each step.
- **New: a one-tap "Back up this profile" shortcut**, right in Settings.
- Backing up is simpler — temporary files are always skipped automatically, and you no longer have to re-enter your password to confirm.
- Before backing up, restoring, or deleting a profile, WebLibre now clearly explains that the app needs to restart, and what that means for any open private tabs.
- Fixed restoring an older backup sometimes permanently signing you out of your Firefox Sync account if your session had expired — WebLibre now keeps your account and sync setup intact and simply asks you to sign back in.

## Firefox Account Sync

Bookmark, history, and tab sync uses a **Firefox Account** (the same account system Firefox itself uses).

- Fixed the sync screen sometimes briefly showing "Not signed in" right after opening it, even though you were signed in.
- Fixed the "syncing…" indicator getting stuck or flickering.
- Renaming a device now updates everywhere immediately, without needing to restart the app.

## WebLibre Account

Separate from Firefox Sync, your **WebLibre Account** covers things like Supporter status and app-level sign-in.

- Fixed a rare case where a successful sign-in could be lost after restarting the app.
- Revoked or expired sessions are now handled differently from manually signing out, so you don't lose recovery access unexpectedly.
- Older "unclaimed" sign-ins are explained more clearly and can be fixed from the Account screen.
- Old or corrupted account data no longer breaks the Account screen.

## Reliability

- Tabs are less likely to reload from scratch after you've been away from the app for a while.
- If a web page itself crashes, its tab now reloads automatically instead of getting stuck on a blank white screen.
- Links and shares from other apps now reliably open in WebLibre — previously, tapping a link right as WebLibre was starting up could silently do nothing.
- Fixed the previous page briefly flashing on screen when leaving the browser for another screen, like Settings.
- Fixed a rare crash when closing an add-on's settings while it was still loading.

## Privacy & Safety

- **New: allow screenshots in private tabs** — they're still blocked by default, and the separate Screenshot Protection setting, if enabled, still blocks screenshots everywhere in the app regardless.

## Zoom & Web Content

- **New: Zoom on All Websites** — lets you pinch-to-zoom even on pages that try to prevent it. Off by default.
- Pressing Enter in the address bar now completes the suggestion shown, instead of ignoring it — unless you'd already chosen otherwise.
- Quitting the browser now immediately clears any containers you've set to clear their data on exit.

## Extensions & Interface Polish

- Installing add-ons is more reliable, especially right after opening a new tab, and leaving an add-on's page mid-install no longer leaves it stuck.
- Search and filter buttons in History, Downloads, and Bookmarks now work the same way across all three screens.
- The home screen search widget now matches your device's light or dark theme, and can pick up your device's own colors on newer Android versions (Android 12+'s "Material You" theming).
- Fixed some permission pop-ups (for example, from add-ons) not matching the rest of the app's look.

## Performance

- Smoother scrolling, snappier tab lists, and less lag when switching tabs or opening menus — especially if you have lots of tabs, containers, or feed articles.
- Faster startup, and the app avoids redoing work that hasn't changed since last time, like refreshing site icons or rebuilding built-in databases.

## Engine Update

- Updated browser engine (GeckoView 155) with the latest website compatibility, stability, and security fixes.
- The default rendering engine is back to the classic "Skia" one, after a brief experiment with Google's newer **Impeller** engine turned up issues — most people won't notice any visual difference. A separate Impeller build is still available if you want to help test it.
- GitHub release downloads now include a version for emulators and x86-based tablets or Chromebooks.

## Upgrade Notes

- App Links starts in "Ask" mode with no sites remembered yet — nothing changes automatically.
- Website Notifications stay off until you choose a UnifiedPush delivery app for them.
- Your bookmarks, folders, and existing settings all carry over as they were.
- Screenshots in private tabs stay blocked unless you turn on the new setting.
- If you were trying the experimental Impeller rendering engine, it keeps working as its own separate install.
- This engine update removes Mozilla's built-in automatic cookie-banner handling (upstream discontinued it) — if you relied on it, a content-blocking extension like uBlock Origin can take over that job.
- Settings Export & Import is not a replacement for a full profile backup.

## 0.20.0
### GeckoView 152.0.4

This is the largest WebLibre release to date, consolidating fifteen alpha releases since v0.11.0. It introduces a full proxy management system, a local full-text search index, configurable touch gestures, a redesigned tab switcher with vertical side rails, container-aware history, and a major desktop mode overhaul.

## Highlights

- **Proxy Management** — sing-box powered proxy profiles with per-container and global routing
- **Local Search Index** — full-text search of the pages you visit, entirely on-device
- **Touch Gestures** — draw gestures on web pages to navigate and control tabs
- **Tab Stacking** — redesigned quick tab switcher with new Accordion and Two Rows layouts
- **Vertical Side Rail** — place the tab bar on the left or right edge of the screen
- **Container-Aware History** — see and filter which container a visit came from
- **Desktop Mode Overhaul** — global, per-site, and per-tab desktop mode control
- **Pure Black (OLED) Theme** — true black backgrounds in app and reader mode
- **Engine Upgrade** — Mozilla Components / GeckoView 152.0.4

## Proxy Management (New)

- **Sing-box proxy profiles** — Create and manage custom proxy connections supporting SOCKS, HTTP, Shadowsocks, VMess, VLESS, Trojan, Hysteria, Hysteria2, TUIC, SSH, WireGuard, ShadowTLS, and AnyTLS. Each profile runs its own managed tunnel with live status indicators, latency chips, and IP display.
- **Six ways to import** — Manual configuration, subscription URLs, QR code scan, clipboard paste (auto-detects `ss://`, `vmess://`, `trojan://` and similar URIs), WireGuard config files, or raw sing-box JSON outbounds.
- **Per-container proxy routing** — Assign any proxy profile or Tor to a specific container; tabs in that container route through the assigned proxy.
- **Global proxy routing** — Route all regular tabs through a single proxy, with a separate assignment for private tabs. Individual containers can bypass the global proxy to connect directly.
- **Profile management screen** — All profiles (including Tor) with protocol badges, run/stop toggles, latency testing, and a "Stop All" button.
- **Per-request DNS leak protection** — DNS leak guarding runs per-request and per-container inside the proxy layer.
- **Profile sharing and logs** — Export profiles as `weblibre-proxy://` URIs, and inspect the sing-box runtime with a real-time log viewer.

## Local Search Index (New)

- **Full-text search of browsed pages** — Visited pages are indexed locally, enabling on-device content search without sending any data off your device.
- **Fine-grained control** — Toggle the index globally, choose whether private tabs are indexed, and exclude individual containers. Excluded containers have their history removed from the index immediately.
- **Index management** — See how many pages are indexed and clear the index at any time while keeping your history. Stale entries are pruned automatically.

## Containers

- **Strict Mode** — Restrict a container so only its assigned sites can load there; unassigned sites are blocked. Requires cookie isolation.
- **Exclude from History** — Prevent a container's visits from being recorded in browsing history (separate from the search index opt-out). Requires cookie isolation.
- **Icon picker** — Choose from over 5,000 Material Design Icons for container branding, shown in the container bar, lists, and tab indicators.
- **Custom colors** — In addition to the refreshed standard palette, a custom color picker with hex and HSL controls is available, applied consistently across chips, lists, selectors, and tab UI.
- **Pinning and reordering** — Pin containers to keep them at the top of lists, and long-press-drag chips in the bottom bar to reorder them.
- **Redesigned management UI** — The container list, selection sheet, and editor were overhauled with card layouts, tab counts, proxy info, and privacy badges.

## Container-Aware History

- History entries can now display which container a visit came from, and the History screen can be filtered by container.
- With a container filter active, clearing history only clears that container's history.
- Deleting a container offers to also delete its history; otherwise those visits are kept without a container label.
- Note: existing history is not retroactively assigned to containers; labels apply to newly recorded visits and are local to WebLibre.

## Tabs and Tab Switching

- **Tab Stacking** — The quick tab switcher was redesigned and is configured under Settings > Toolbar Layout > Tab Stacking, with new layouts:
  - **Accordion** — containers as chips, expanding the selected container inline
  - **Two Rows** — the selected container's tabs on one row, recently used tabs on another
  - Plus the existing Recently Used Tabs, Container Tabs, and Disabled modes. Existing settings are migrated automatically.
- **Vertical side rail** — The tab bar can be placed on the left or right edge as a vertical rail with address controls, toolbar actions, and pinned add-ons. Swipe vertically on the rail to switch tabs.
- **Customizable switcher buttons** — Choose which action buttons appear at the end of the tab switcher bar, configured independently from the contextual toolbar.
- **Tab hierarchy tools** — Long-press a tab for a Hierarchy submenu (change parent, detach, reorder among siblings). Drag-and-drop can group two tabs in a new container or establish a parent-child relationship. Manual reorganizations are preserved and no longer overwritten by engine state.
- **Depth indicators** — Nested tabs show chevron badges revealing nesting depth, with configurable depth display and compact badges on narrow layouts.
- **Switcher polish** — Drag-to-reorder in the switcher, container-colored tab bar, tab counts on container chips, optional close buttons on every chip, reliable centering of the active tab, and clearer marking of pinned, private, isolated, and nested tabs.
- **Faster, safer startup restore** — Restored tabs appear earlier as placeholder chips while the engine finishes restoring; tapping one queues the selection. Saved tab data is only cleaned up after the engine confirms restore is complete.

## Touch Gestures (New)

- Draw gestures on web pages to navigate, control tabs, and trigger page actions. Off by default; enable under Settings > Gestures.
- A stroke interval setting prevents accidental triggers from fast, jittery movements.
- Pull-to-refresh no longer accidentally triggers on gesture strokes near the top of the page.
- Long-press the gestures toggle in the browser menu to jump straight to gesture settings.

## Desktop Mode

- **Global desktop mode** — "Always Request Desktop Site" under Settings > Browsing > Desktop Mode applies to every tab, including already-open ones.
- **Per-site desktop mode** — Maintain a list of sites that always load in desktop mode, regardless of the global setting. Add sites from the page menu or manage the list in settings. Subdomains are covered automatically.
- Per-tab toggling continues to work as before and takes precedence.

## Reader Mode

- **True black (AMOLED) reader theme** — With Pure Black enabled, the reader's dark theme is genuine black.
- **Refreshed article layout** — Improved spacing and typography, edge-to-edge images, nicer quotes and lists, and properly wrapped code blocks.
- The appearance button now toggles open/closed, appearance controls no longer hide behind the bottom toolbar, and a "show toolbar" button is available while reading with the toolbar hidden.

## Appearance and Home Screen

- **Pure Black (OLED)** — Settings > General > Pure Black switches dark mode backgrounds to true black, saving battery on OLED screens.
- **Refresh Rate setting** — System, High, or Low under Settings > General; High (the default) makes scrolling smoother on 90/120 Hz displays, Low reduces battery usage. Android-only, depends on device support.
- **System bar tinting** — Status and navigation bar areas match the active container or toolbar color, with icon contrast adjusted automatically.
- **Reworked home screen** — Quick actions (New tab, View tabs, Resume last tab) moved near the top, plus a dismissible "Support WebLibre" banner explaining the optional Supporter subscription. The browser and all privacy features remain free.
- **New app icon** — Refreshed launcher icon including adaptive and monochrome variants.
- "Top Sites" has been renamed to "Shortcuts" throughout the app.
- Optional close button on the new tab / search screen (Settings > General > Show Close Button), handy on e-ink devices.

## Search and Bangs

- **Popular Sites suggestions** — The search screen and address bar autocomplete now suggest well-known websites, so even a fresh install completes "git" to "github.com".
- **Reverse bang matching** — Pasting a URL produced by a bang search (for example a Google search result URL) recognizes the bang template and swaps the URL for the extracted query with the bang pre-selected.
- **Bang robustness** — Bangs match correctly across `www.`, bare, and `m.` domain variants; custom bang editing handles URL encoding safely and trims accidental whitespace; typed text is preserved when switching search providers; selecting a bang highlights the existing query for quick replacement.
- **Find in page integration** — Tapping a search result from history or the local index prompts to find that text on the page instead of opening the find bar uninvited.
- An "Autocomplete on Submit" setting accepts inline suggestions when pressing Enter.

## Privacy and Security

- **Expanded hardening** — Over 30 additional telemetry, experiment, and tracking preferences are locked against upstream Gecko updates silently re-enabling them. Locked settings show a padlock icon.
- **Private tabs notification** — A persistent notification appears while private tabs are open; tapping or swiping it closes them all.
- **Better .onion handling** — Onion addresses typed without a scheme open over `http://`, and HTTPS upgrades are no longer forced for onion services (explicitly typed `https://` onion addresses keep HTTPS).
- **Tracking protection** — Custom Tracking Protection gains a separate switch for ads, analytics, and social trackers, plus a Content Blocking Database option for GeckoView's built-in blocklists (requires restart).
- **Recent searches cleanup** — Recent searches can be cleared when deleting browsing data and included in the automatic Incognito Mode cleanup.
- **Referer policy compatibility** — The strictest cross-origin referer mode is now an advanced opt-in instead of the default, fixing breakage on sites that depend on referer information.
- **New lock option** — "Lock on Startup Only" unlocks a protected profile once at app start instead of on every background or timeout.
- The Android "install unknown apps" permission was removed from the manifest.

## Extensions

- **Bookmark access for extensions** — Extensions such as floccus can now read and organize bookmarks, with instant change notifications — unique among mobile Gecko browsers.
- Pinned extensions no longer appear duplicated in the overflow menu, and disabled extensions are hidden from the toolbar and shortcut menu.

## Browser Behavior

- **Custom Tabs toggle** — Decide whether other apps open links in a lightweight in-app tab or as a normal tab in the main browser (enabled by default).
- **Reload doubles as stop** — The reload button shows an X during page load; tap it to cancel loading.
- **Connections menu** — Tor and proxy controls are grouped in a collapsible Connections section of the browser menu with a connected count and quick access to management. The browser menu quick toggles use a segmented control.
- **Improved Picture-in-Picture** — Fullscreen video behaves reliably when pressing Home, switching apps, or returning to WebLibre; accidental PiP triggers from permission prompts are fixed.
- **Site data clearing** — "Clear Site Data" can optionally close the current tab after clearing.
- Link context menus can open a link as a different tab type (regular, private, or isolated).

## Downloads

- Completion and failure snackbars, with an "Open" action to launch finished files.
- Tapping a download in history opens it with the appropriate system app.
- Correct filename resolution, saving downloads to the system Downloads directory with proper names.

## Settings

- **Global settings search** — Search across all categories from the main Settings screen; results show breadcrumbs, and tapping one navigates, auto-scrolls, and highlights the exact entry.
- New top-level Proxy category, an ML Downloads entry in Advanced Settings to clear downloaded AI models, and remembered bookmark list preferences (sorting and folders-only view).

## Tor

- **Service reliability overhaul** — Fixed race conditions in service binding, proper foreground service lifecycle, bootstrap polling fallback, and pluggable transport (obfs4, snowflake) port readiness polling. Tor now survives hot restarts and engine reconnections.
- Updated Tor components with newer upstream fixes.

## Platform and Performance

- **Engine upgrade** — Mozilla Components / GeckoView 152.0.4 with newer web compatibility, performance improvements, and upstream fixes.
- **Impeller graphics engine** re-enabled for smoother rendering and animations.
- **Smaller, faster builds** — Release builds use code and resource shrinking (R8 optimization).
- **Reduced background work** — Browser screenshot work is skipped while full-screen panels (Settings, Search, Tabs) are open, and an advanced option can unload the web engine under full-screen overlays to free resources.
- **Samsung and gesture navigation fixes** — System back gestures no longer cause unwanted page scrolls, and the home screen search widget is resizable with correct sizing.
- **Better multi-window support** — Split-screen, freeform, and pop-up window resizing works smoothly, with taps landing in the right place.
- Cold-start intent replay makes sharing links to WebLibre reliable even when the app was not running, and improved compatibility with older Android versions.

## Notable Fixes

- Fixed broken navigation after cancelling an "open in app" prompt.
- Fixed tab churn when a site is assigned to a container: tabs already in the correct container are left alone.
- Fixed site-assigned containers not taking precedence over the currently selected container, including for shared content.
- Fixed tab hierarchy and parent relationships being lost to engine race conditions.
- Fixed keyboard and auto-hiding toolbar layout issues, including the toolbar getting stuck after keyboard changes.
- Fixed custom tab toolbar sizing, reappearance, and color scheme issues.
- Fixed the QR scanner to request camera permission up front and fail gracefully when denied.
- Fixed PWA popup and window-open handling for login and payment flows, and rare failures when reopening an existing web app window.

## Upgrade Notes

- Existing Quick Tab Switcher settings are migrated to the new Tab Stacking options automatically; new installs default to Accordion when container UI is enabled.
- Existing browsing history is not retroactively assigned to containers.
- The Content Blocking Database setting requires an app restart to take effect.
- Container Strict Mode and Exclude from History both require cookie isolation to be enabled for the container.

## 0.11.0
### GeckoView 150.0.1

**Extension Management**

- **Redesigned Extensions System** — The entire add-on system has been rebuilt, replacing the legacy native Android screens with a smoother in-app experience. Browse, search, install, and manage extensions all within the app.
- **Add-on Store** — Discover recommended extensions directly in the app with segmented categories and a streamlined install flow.
- **Add-on Detail Screens** — View permissions, internal settings, and popups for each extension without leaving the app.
- **Pinned Add-on Bar** — Quick-access bar in the browser toolbar for your favorite extensions, with bottom-sheet popups.
- **Update All Extensions** — One-tap button to check for and install updates for all your installed extensions at once.
- **uBlock Origin Filter List Management** — Browse, enable, and disable individual uBlock Origin filter lists. Add custom external filter lists and apply recommended hardening filters for extra privacy.

**Privacy & Security**

- **Intent Gatekeeper** — When another app tries to open a link, WebLibre can now ask whether to allow or block it. Manage per-app permissions and respond from notifications without opening the browser.
- **Screenshot Protection** — New privacy setting to block screenshots and screen recordings of the browser. Find it under Settings > Privacy & Security.
- **Permission Shield Indicators** — The shield icon on your tab now uses colors to show your privacy status: green means enhanced protection, yellow means you've loosened settings for this site, and it's hidden when everything is at default.
- **Third-Party Redirect Blocking** — Enabled by default to protect you from malicious redirects.
- **Smarter Onboarding Defaults** — New users automatically get recommended privacy defaults, including uBlock Origin with optimized filter lists and engine-level privacy hardening.
- **Fixed Site Data Clearing** — Clearing cookies or site data now properly closes affected tabs first, preventing old data from reappearing immediately.

**Tab Management**

- **Tree View Everywhere** — View your tabs in a hierarchical tree structure in List and Grid views too, so you can always see which tabs opened from which.
- **Reorder Tabs in Groups** — Manually reorder tabs within groups for full control over your browsing layout.
- **Auto-Scroll to Active Tab** — The active tab now smoothly scrolls into view when you open any tab view (list, grid, tree, or quick switcher).
- **Pinned Tabs Respected Everywhere** — Pinned tabs now stay at the top in the quick tab switcher and grid view too, not just the list.
- **Quick Tab Switcher Always MRU** — The quick-switcher bar always shows your most recently used tabs first for consistent muscle memory.
- **Container Tab Colors on Title Bar** — When browsing in a container, the address bar now shows a subtle colored border matching your container's theme.
- **New Sorting Options** — Choose whether new tabs appear at the top or bottom (or left/right) of your tab lists.
- **Stronger Session Restore** — A new internal system reduces the chance of duplicate tabs appearing after restart.
- **Isolated Tabs Persist** — Isolated tabs now properly survive quitting the app (only private tabs are cleared on exit).

**PWAs & Home Screen Shortcuts**

- **Custom Names for Shortcuts** — Give your home screen shortcuts any name you want instead of being stuck with the website's default title.
- **Storage Context for Shortcuts** — Choose how each shortcut handles logins and data: normal storage, share with an existing container, inherit your current isolated session, or create a fresh isolated context — perfect for using multiple accounts on the same site.
- **Multiple Shortcuts Per Site** — Pin the same website multiple times with different names and storage contexts (e.g., personal account and work account).
- **Better Shortcut Icons** — Shortcuts now always get an icon, even for sites that don't provide one.
- **Smarter PWA Launches** — Opening a PWA that's already open now brings it to the front instead of starting a duplicate.
- **PWA Session Recovery** — PWAs that lose their session (e.g., after the browser is killed) now automatically recover instead of crashing.

**Export & Sharing**

- **Export Page as Image** — Save any webpage as a PNG image to your device.
- **Copy Images from Image Menu** — Long-press any image to copy it directly to your clipboard.
- **Smarter Text Sharing** — When sharing text or URLs into WebLibre from other apps, they now properly route through containers and custom tabs.

**Search & Navigation**

- **History Toolbar Button** — Optional quick-access button for your browsing history, available from the toolbar customization screen.
- **Better Search Without a Default Engine** — Highlighting text and choosing to search now opens the search screen with your text pre-filled, even if no default engine is set.
- **Fixed Address Bar Ghost Text** — Backspace and delete no longer cause suggestion text to glitch or get corrupted.

**Onboarding & Setup**

- **Restore Backup During Onboarding** — Import an encrypted profile backup right from the welcome screen, before creating any profile.
- **Alpha & Stable Side by Side** — You can now keep both the stable and alpha versions installed at the same time as separate apps, so they don't interfere.
- **Optimized Defaults** — When installing uBlock Origin during setup, you can opt in to recommended privacy filter lists automatically.
- **Automatic Preference Migration** — A new system keeps your settings up to date automatically when new features are added.

**UI & Polish**

- **Redesigned Toolbar Customization** — Toolbar settings now separate buttons into "Enabled" and "Disabled" sections for a clearer overview.
- **Long-Press Menu for Settings** — Long-press the menu button (...) in the toolbar to jump directly to Settings.
- **Quick Quit on Long Press** — Long-press the "Quit" button in the profile menu to exit immediately, skipping the confirmation dialog.
- **Clearer Site Data Options** — The site data cleanup screen now shows Cookies and Cached Files as sub-options under Site Data, making it easier to understand what you're clearing.
- **Unsaved Changes Warning** — Editing a container and pressing back without saving now asks whether to save, discard, or keep editing.
- **Better Keyboard Handling** — The bottom sheet now adjusts to the keyboard height so content is never hidden.
- **Improved URL Display** — URLs are formatted more cleanly with better special character handling.
- **Addon Store Screenshot Viewer** — Tap a screenshot in the addon details page to view it in a zoomable overlay.
- **Proper Quick Action Icons** — The Android launcher long-press shortcuts now show proper icons instead of blank tiles.

**Bug Fixes**

- Fixed ghost text and clipping artifacts in the address bar
- Fixed PWA launch duplication when the app was already open
- Fixed overlapping UI elements when the floating action button is visible
- Fixed tab bar long-press interactions
- Fixed small web mode handling of isolated tab types
- Fixed toolbar preview layout overlapping with the action button

## 0.10.1
### GeckoView 149.0

**New Features**

**Small Web Discovery**
A brand new browsing mode to discover personal blogs, indie creators, and handcrafted websites from around the internet.
- **Kagi Small Web** — Browse curated content from community-vetted sources in 5 modes: Web, Appreciated, Videos, Code, and Comics
- **Wander Network** — Explore a decentralized network where personal websites recommend each other, forming a web of serendipitous discoveries
- **Topic Filters** — Narrow discoveries by 22 categories including AI, Programming, Science, Art & Design, Gaming, Travel, and more
- **Discovery History** — Track and revisit pages you've found, with smart avoidance of recently seen content

**PWA (Progressive Web App) Support**
- Install websites as standalone apps and create home screen shortcuts for quick access
- Enhanced PWA installation dialog with more options
- Fixed PWA display mode detection

**Custom Backup Directory**
- Choose where to store your profile backups — any folder on your device or external storage
- Backups stored outside the app survive reinstallation
- Old backups are automatically migrated when you select a new location
- New "Skip Cache Directories" option significantly reduces backup file size

**Permanent "Allow Unsigned Extensions" Setting**
- Enable unsigned extensions permanently from Settings > Extensions > Security, instead of confirming each time
- Includes security warnings and a confirmation dialog

**Quality of Life**
- Long press on tab bar URL to copy it to clipboard

**Updates**

- **Upgraded browser engine to Gecko 149.0** — Latest performance improvements and security fixes from Mozilla
- **Updated bang data** with spec-enforced bang naming
- **Consolidated bang groups** — The separate "assistant" bang group has been merged into the "kagi" group for simpler management (existing assistant bangs are automatically migrated)

**Bug Fixes**

- Fixed Small Web session occasionally showing stale/empty state after app restart
- Fixed PWA display mode detection
- Thumbnails are no longer captured while in fullscreen mode
- Restored certificate requirement for installing unsigned extensions (security)
- Fixed long press actions incorrectly forwarded in custom tabs
- Show minimal context menu in PWA/custom tabs

## 0.10.0
### GeckoView 148.0.2

**Major New Features**

- **Progressive Web App (PWA) Support** - Install compatible websites directly to your home screen as standalone apps. PWAs open in their own window with their own icon, and remember which profile and container they belong to.

- **Custom Tabs Integration** - Other Android apps can now open links in WebLibre using a lightweight browser overlay. Includes a close button to instantly return to the calling app, with support for private browsing mode.

- **Built-in Page Translation** - Translate any webpage into your preferred language - locally on your device. The browser automatically detects the page language and offers translation options.

- **Firefox Sync** - Connect your Firefox account to sync bookmarks, open tabs, and browsing history across all your devices. Set up via QR code or direct sign-in. Send tabs to your other devices and view tabs open on synced devices.

- **URL Cleaner & Unshortener** - Automatically removes tracking parameters from URLs and reveals the final destination of shortened links. Based on ClearURLs rules with automatic weekly updates.

- **Isolated Tabs** - A new tab type that runs in complete isolation from your other browsing, perfect for sensitive tasks like banking.

- **New Browser Home Screen** - The empty tab screen is now a proper home experience with inspirational quotes, quick actions, and container-aware content.

- **Dedicated Extensions Settings** - New screen to install extensions from local .xpi files and configure custom Mozilla addon collections.

- **Tor Country Picker** - New searchable country picker with flags for selecting Tor entry and exit node countries.

**Search & Navigation**

- **Top Sites Grid** - Your most-visited sites in a customizable grid. Pin favorites, edit titles, drag to reorder, and hide unwanted sites.
- **Customizable Search Modules** - Reorder and toggle search sections (Top Sites, Recent Tabs, History, Bookmarks, Containers).
- **Bookmark Search** - Search your saved bookmarks directly from the search bar.
- **Animated Tab Type Switcher** - Smooth pill-style selector for regular, private, and isolated tabs.

**Export & Share**

- **Print & Export Pages** - Print any webpage or save as PDF. Export page content as Markdown (clean reader content or full page), or copy as Markdown to clipboard.

**Tab Management**

- **Tab Filtering & Sorting** - Filter by type (regular, private, isolated) and sort by title, URL, or date range.
- **Drag-and-Drop Container Creation** - Drag one tab onto another to create a new container with AI-suggested names.
- **Tab List Options** - Show favicons instead of thumbnails, show/hide tab titles in quick switcher.

**Privacy & Security Hardening**

- **Certificate Transparency** - Enforce CT checks and CRLite for certificate revocation.
- **WebGL Privacy** - Spoof renderer and vendor information.
- **WebRTC IP Leak Prevention** - mDNS obfuscation, relay-only mode options.
- **Safe Browsing** - Toggle malware and phishing protection.
- **Geolocation Privacy** - Uses BeaconDB instead of Mozilla's service.
- **API Restrictions** - Battery API, Reporting API, and WebGPU disabled by default.

**New Settings**

- **UI Scale Factor** - Adjust overall interface size.
- **Font Size Control** - Scale web page text from 50% to 300%.
- **Disable Animations** - Reduce motion for accessibility.
- **Experimental Process Isolation** - Isolated content process and App Zygote for enhanced security.
- **Reset All Preferences** - One-tap button to restore all settings to their defaults.

**Customization**

- **Configurable Toolbar Buttons** - Reorder, enable/disable, reset to defaults.
- **Long-Press Actions** - Additional actions on toolbar buttons.

**Improvements**

- **Improved Keyboard Handling** - Better height calculation prevents hidden content.
- **Unified Bottom Sheet Menu** - Navigation drawer replaced with consolidated bottom sheet.
- **Settings Reorganization** - Clearer categories: General, Browsing, Web Content, Search, Extensions, Privacy & Security, Advanced, Experimental.
- **Enhanced Onboarding** - DNS over HTTPS, toolbar customization, and privacy hardening options.

**Removed**

- Navigation drawer (replaced by bottom sheet menu)
- Auto-launch docs after onboarding
- Dismiss confirmation on bottom app bar

## 0.9.32
### GeckoView 147.0.2

**Bug Fixes**
- Fixed bookmarks routing issue

## 0.9.31
### GeckoView 147.0.2

**New Features**
- Added per-site tracking protection controls
  - Site-specific tracking protection exceptions
  - New tracking protection exceptions management screen
  - Per-site permissions management (location, camera, microphone, notifications, autoplay, etc.)
- Added clear browsing data per domain
- Added custom tracking protection policies
  - Granular tracking protection configuration
  - Configurable blocking categories and levels
  - Custom tracking protection settings screen
- Added external download manager support
  - Option to use external download managers instead of built-in handler
  - Configurable in tabs behavior settings
- Added extension installation from local XPI files
  - Install browser extensions from local .xpi files
- Added QR code scanner
  - Built-in QR code scanning integrated into search field
  - Quick access for scanning URLs
- Added Tor entry/exit country selection
  - Configure specific countries for Tor entry and exit nodes
  - Enhanced Tor settings UI with country picker
- Added "Open in App" feature
  - Native app link handling for compatible apps
  - Configurable app links behavior

**Major UI/UX Improvements**
- Complete browser UI scaffold replacement
  - Better keyboard handling with bottom sheets
  - Improved content overlay management
  - Top bar now hides on scroll
- Navigation drawer reorganization
  - New dedicated navigation drawer
  - Reorganized button placements
  - Unified toolbar icon colors
  - Improved profile selector bottom sheet
- Converted dialogs to bottom sheets for better mobile UX
  - Delete data, folder selection, profile selection, and feed selection
- Address bar merged into search screen
  - Unified search and URL input experience
  - Tab editing integrated into search interface
- App color system reorganization
  - Consistent color scheme across entire app
  - Improved visual hierarchy
- Movable tab bar restore button
  - FAB can be repositioned by user
  - Drag to preferred location

**New Settings**
- Settings reorganization with new categories:
  - General Settings
  - Privacy & Security Settings
  - Search & Content Settings
  - Tabs & Behavior Settings
  - Appearance & Display Settings
  - Fingerprinting Settings
  - Advanced Settings (renamed from Developer Settings)
- Disable automatic clipboard access for improved privacy
- Auto-clear unassigned tabs after configurable duration
- Configurable search history entry count with automatic cleanup
- Control swipe-to-refresh gesture
- Disable double back to close tab gesture
- External download manager toggle
- App links handling control

**Container & Tab Management**
- Container assignment improvements
  - Fixed container assignment for private tabs
  - Container selection in new tab screen
  - Better container data synchronization
- Tab closing logic improvements
  - Check for parent tab first when closing (fixes #155)
  - Close assigned tab when history is empty
  - Improved tab bar dismiss logic (fixes #157)
- Tab view enhancements
  - Improved initial scroll position
  - Hide "Add New Tab" button on scroll
  - Better grid/list scroll behavior

**Bookmarks & History**
- Bookmark all tabs dialog with fast/detailed options
- Hide empty root folders by default
- Long press for history navigation
- Edit mode respected in history search

**Search Enhancements**
- Configurable search history entry count
- Automatic search history cleanup
- Case-insensitive suggestion matching
- Autocomplete suggestions on tap

**Tor Improvements**
- Migrated from Arti to libtor implementation
- Country selection for entry/exit nodes
- Improved Tor UI and notifications
- Custom onion icon in notifications

**Developer & Debugging**
- New dedicated error logs screen
- Improved error logging and handling
- Log filtering capabilities

**Performance & Resource Management**
- Improved image caching and disposal
  - Better widget icon caching
  - Proper image disposal to prevent memory leaks
- Screenshot timer management improvements
- Better database provider lifecycle management
- Longer disposal timeout for improved resource cleanup

**Visual Improvements**
- Permission badge indicator in address bar
- Better find-in-page widget with debouncing
- Progress bar positioning based on toolbar location
- Fixed PlatformView overlap issues on affected devices running old Android versions
- Improved keyboard visibility handling

**Bug Fixes**
- Fixed container assignment issue for private tabs
- Fixed tab bar dismiss logic (fixes #157)
- Fixed parent tab check when closing tabs (fixes #155)
- Fixed provider access errors on dispose
- Fixed loading progress visibility issues
- Fixed color issues with new app colors
- Fixed PlatformView overlap issues
- Fixed content overlay issues

## 0.9.30
### GeckoView 146.0.1

**New Features**
- GitHub and Google Play releases are using libre Fennec-style Gecko builds from now on (on par with F-Droid)
- Added encrypted profile backup and restore system with password protection
- Added bookmark import/export functionality
  - Support for HTML (Netscape format, Firefox/Chrome compatible) and JSON formats
  - Option to merge with existing bookmarks or replace completely
- Added private tab tracking system
  - Visual indicator (private icon) in address bar for private tabs
  - "Close All Private Tabs" button in tab view
- Added page content export capabilities
  - Export current page as PDF file
  - Copy page content as Markdown to clipboard
  - Save page content as Markdown file
- Added multiple tab view modes
  - Grid view: Traditional grid layout
  - List view: Compact list showing more tabs at once
  - Tree view: Hierarchical display of tab relationships
  - View mode preference persists across app restarts
- Added quick tab switcher and contextual navigation bar
  - Contextual bottom toolbar showing recently used tabs or ordered container tabs (configurable)
  - Dismissible to maximize screen space
- Added container filter for tree view to show container-specific tab hierarchies
- Added ML model download progress reporting with real-time indicators
- Added isolated container data clearing
  - Clear cookies, cache, and browsing data for specific containers
  - Option to clear container data on exit
- Added quit button to profile selector for complete app exit
- Added address bar auto-focus option for improved navigation UX

**Improvements**
- Complete tab bar overhaul
  - Consolidated menu buttons for cleaner interface
  - Tab reordering now opt-in via settings (not always enabled)
  - Tab bar dismissible to maximize viewing space
- Enhanced container color system
  - Tab bar color now matches current container's color theme
  - Selected containers use border instead of background color (improved visibility)
- Redesigned search interface
  - Improved visual hierarchy and layout
  - Better organization of suggestions, history, and results
  - Enhanced container chip display
  - More efficient use of screen space
- Improved tab handling and state management
  - Better tab duplication logic
  - Enhanced tab parent handling and hierarchy management
  - Refined tab insertion process
  - Removed tab deletion cache for simplified architecture
- Enhanced bookmark management
  - Assignable folder parents (move bookmarks between folders)
  - Improved bookmark entry editing interface
  - Better folder management and organization
- UI/UX enhancements
  - Tab icons displayed when screenshots unavailable
  - Less intense chip background colors for better readability
  - Auto-hide "Add New Tab" button for cleaner interface
  - Automatic UI reset after 30+ minutes of inactivity
  - Updated addon/extension layouts
  - Various icon updates throughout the app

**Bug Fixes**
- Fixed search field focus issues preventing proper keyboard interaction
- Fixed disposed provider exceptions that could cause crashes
- Fixed unmounted widget exceptions
- Fixed browser floating action button animation glitches
- Fixed tab container provider lifecycle coordination
- Fixed widget/provider lifecycle timing issues
- Fixed incorrect tab hierarchy when adding multiple tabs (parent ID handling)
- Fixed tab menu incorrectly showing for history items
- Improved animation smoothness throughout the app

## 0.9.29
### GeckoView 145.0.2

**New Features**
- Added container site assignments to automatically open specific websites in designated containers
- Added multi-user profiles with complete separation of browsing data, extensions, and settings
- Added bookmarks feature
- Added support for custom search engines via user-defined bangs

**Improvements**
- Tor now uses built-in bridges as fallback
- Tor data storage migrated from file directory to cache
- Arti logging now outputs to logcat
- Tab overview now defaults to fullscreen mode (configurable in settings)
- Visual indicator added to tab bar for Tor-tunneled tabs
- Reorganized menu structure
- General UI improvements and bug fixes

## 0.9.28
### GeckoView 144.0.2

**New Features**
- Added support for requesting sites in Desktop Mode

**Improvements**
- Enhanced favicon caching
- Tor-related updates and improvements
- UI refinements

**Bug Fixes**
- Fixed URL launch intent issues

## 0.9.27
### GeckoView 144.0

**New Features**
- Added setting to disable internal PDF viewer (pdfjs)
- Added setting to define and select browser locales

**Improvements**
- Migrated from experimental API extension to new Gecko Preference API for most operations

**Bug Fixes**
- Fixed UI issues
- Fixed engine crash after prolonged background inactivity
- Fixed intent stream lifecycle issue

## 0.9.26
### GeckoView 144.0

**Bug Fixes**
- Ensure tab bar remains visible when bottom sheet is active
- Handle AI engine errors gracefully
- Fix container assignment when opening links
- Fix settings toggle not refreshing UI

## 0.9.25
### GeckoView 144.0

**New Features**
- Added AI feature to group related unassigned tabs into new containers
- Added setting to control how externally opened links are handled (now defaults to prompt)
- Added DoH (DNS over HTTPS) setting with predefined or custom DNS resolver options
- Added browser history view with options to view and delete history data
- Added tab bar swipe action setting with options: "Switch to last used Tab" and "Navigate Sequential Tabs"
- Added quick actions to open tabs via long press on home screen app icon
- Added developer setting to support third-party CA certificates
- Added support for custom addon collections
- Added developer setting to customize fingerprint protection measures

**Improvements**
- Rewrote large portions of the Tor Plugin with option to route all traffic and fixed potential IP leaks (through browser side effects like loading favicons)
- Increased Tor background service timeout from 15 minutes to 1 hour without interaction
- Localhost URLs now default to `http` instead of `https` for better compatibility
- Display scrollable breadcrumb representation of URLs wherever possible for improved visibility
- Updated built-in Bangs
- Large portions of UI rewritten and improved

**Breaking Changes**
- New database structure for bangs; saved bang frequency sorting has been reset

## 0.9.24
### GeckoView 143.0.0

* Upgraded GeckoView

## 0.9.23
### GeckoView 142.0.1

**New Features**
- Added Tor Bridge support with automatic configuration and bridge updates
- Added setting to display dialog for choosing external link handling behavior

**Bug Fixes**
- Fixed media upload issues on websites
- Fixed hardening settings UI display problems

**Improvements**
- Enhanced bottom sheet user interface
- Improved URI parsing and protocol detection for address bar input

## 0.9.22
### GeckoView 142.0

* Added setting to use third party CA certificates
* Added setting to control tab bar swipe behavior
* Downgraded AGP for F-Droid compatibility

## 0.9.21
### GeckoView 142.0

* Restore previous tab state on undo delete
* Fix Reader Mode issue on back arrow navigation
* Unhide tab bar on app resume

## 0.9.20
### GeckoView 142.0

* Added 'Undo' action for closed tabs
* Added swipe gesture to close tab
* Added compatibility for receiving intents of various MIME types
* Introduced Bounce Tracking Protection
* Introduced Query Parameter Stripping as setting
* Introduced setting to control default tab type for creating new tabs and opening links
* Upgraded Flutter to latest stable version
* Automatic hide tab bar on scroll
* Sort newly created tabs after parent instead of at front
* Set default fallback encoding for Web Feeds to UTF-8
* Take full screen size when in fullscreen mode
* Improved error logging
* Filter out sensitive logs
* Minor UI improvements
* Fix Reader Mode issue on back navigation
* Fix bottom sheet scrolling issues

## 0.9.17

* Reworked Tab UI into bottom sheet
* Adjusted Android permissions
* Improved Favicon handling

## 0.9.16-2

* Fix icon caching issue

## 0.9.16-1

* Fixed drop animation lag
* Allow drop into the unassigned container

## 0.9.16

* Integrated on-device ai for container naming and tab sugegstions
* Improved Tab and container UI

## 0.9.15-1

* Added certificate information title
* Fixed draggable tabs
* Open single tab in tree view automatically

## 0.9.15

* Improved intent handling
* Refactored tab grid
* Several UI improvements
* Optimized build

## 0.9.14

* Bundle bangs and disable auto fetch (sync from repo still possible via settings)
* Fix flickering after returning from home
* Fix UI website title overflow
* Optimize build

## 0.9.13

* Added option to show extensions in tab bar (through "Show Extension Shortcut" setting)
* Added tab menu action to assign tab to container
* Fixed QR code generation issues
* Switched to Mozilla stable builds
* Fixed issues with PiP and fullscreen mode

## 0.9.12

* Reorganized several settings into a new group: "Developer Settings"
* Added a "Get Extensions" menu entry
* Disabled the Cookie Banner Blocker option, as it is deprecated by Mozilla (consider using uBlock Origin instead)
* Updated hardening presets
* Mozilla Components upgraded

## 0.9.11

* Trigger automatic find-in-page when coming from local search results
* Upgraded gecko
* Upgraded GoRouter

## 0.9.10

* Initial public release