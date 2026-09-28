# SAP CAP — Excel Upload with Fiori Elements

Reference notes for: *"Upload and Process Excel Files in SAP CAP using Fiori Elements"* (AbapExplained, 2026)
Video: https://youtu.be/vWzzqMG3KfM
Reference repo: https://github.com/Frontmaniaac/SAP-CAP-Excel-Upload-with-Fiori-Elements

**Goal:** Upload an `.xlsx` file through a Fiori Elements app → CAP reads it as a stream → parses rows with Node.js → applies business logic → inserts the data into a CAP entity (`BoardGames`).

---

## 1. Project Structure

```
db/
  bg-scheme.cds        # data model: BoardGames + Files (media entity)
srv/
  bg-srv.cds           # service definition + draft annotation
  bg-srv.js            # custom handler: stream → buffer → parse → insert
app/
  board-games/         # Fiori Elements app (viewer for BoardGames)
  file-upload/         # Fiori Elements app (uploader for Files)
  services.cds         # aggregates both apps' annotation files
package.json
```

Two separate Fiori apps were generated (both via BAS Fiori Application Generator,
**List Report Page V4** template, pointing at the same local CAP service):
- **file-upload** → main entity `Files` → used to upload the `.xlsx`
- **board-games** → main entity `BoardGames` → used to view the parsed result

---

## 2. Data Model (`db/bg-scheme.cds`)

```cds
using cuid from '@sap/cds/common';
namespace bg;

entity BoardGames : cuid {
    name            : String(120);
    price           : Decimal(15,2);
    players         : String(20);
    playTimeMinutes : Integer;
    ageRating       : String(10);
}

entity Files : cuid {
    fileName : String(260);
    fileType : String      @Core.IsMediaType;
    content  : LargeBinary @Core.MediaType : fileType
                           @Core.AcceptableMediaTypes: [
                             'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
                           ]
                           @Core.ContentDisposition.Filename: fileName;
}
```

**Key points:**
- `Files` is a generic **media entity** pattern — `LargeBinary` + `@Core.MediaType` is what makes Fiori Elements render an upload/download control instead of a plain field.
- `@Core.AcceptableMediaTypes` restricts the upload control to only accept `.xlsx` MIME type — rejects other files client-side.
- `@Core.IsMediaType` on `fileType` tells the framework this field *stores* the MIME type of the content field.

---

## 3. Service Definition (`srv/bg-srv.cds`)

```cds
using {bg} from '../db/bg-scheme';

service BoardGamesHandler {
    entity BoardGames as projection on bg.BoardGames;
    entity Files      as projection on bg.Files;
}

annotate BoardGamesHandler.Files with @odata.draft.enabled;
```

**Key point:** `Files` needs `@odata.draft.enabled` — Fiori Elements' upload control on an Object Page generally requires draft mode to handle the create/upload transaction properly.

> No `cds add` command scaffolds this file's content — it's hand-written. (See earlier note: only `cds add handler` scaffolds *implementation* stubs, not service model files.)

---

## 4. Custom Handler Logic (`srv/bg-srv.js`)

This is the core of the tutorial — an `ApplicationService` override that intercepts `CREATE` on `Files`:

```js
const cds = require('@sap/cds');
const readXlsxFile = require('read-excel-file/node');

module.exports = class AttachmentHandler extends cds.ApplicationService {
  init() {
    const { BoardGames, Files } = this.entities;

    this.on('CREATE', Files, async (req, next) => {
      // 1. Stream → Buffer
      const chunks = [];
      for await (const chunk of req.data.content) chunks.push(chunk);
      const buffer = Buffer.concat(chunks);

      // 2. Parse xlsx buffer into rows
      const rows = await readXlsxFile(buffer);
      const [header, ...body] = rows;

      // 3. Map rows → entries + apply business logic
      const entries = body.map(([name, price, players, playTimeMinutes, ageRating]) => ({
        name,
        price: Number(price) * 2,   // example business rule
        players,
        playTimeMinutes: Number(playTimeMinutes),
        ageRating
      }));

      // 4. Persist into BoardGames
      for (const entry of entries) await INSERT.into(BoardGames).entries(entry);

      return next();
    });

    return super.init();
  }
};
```

**Flow to remember:**
1. `req.data.content` on a media/stream field arrives as an **async-iterable stream**, not a buffer — must consume it chunk by chunk (`for await...of`).
2. `Buffer.concat(chunks)` turns the stream into one binary buffer `read-excel-file` can parse.
3. `readXlsxFile(buffer)` (Node build of `read-excel-file`) returns rows as arrays; first row = header, rest = data.
4. Destructure each row by column position → map to target entity shape.
5. Business logic (e.g. price transform) happens in plain JS before insert.
6. `INSERT.into(...).entries(...)` in a loop — fine for demo/small files; for large files batch the array into a single `.entries(...arrayOfEntries)` call instead of looping.
7. Always call `next()` (or `return next()`) to let the generic handler continue and actually persist the uploaded `Files` row itself.

---

## 5. Dependencies (`package.json`)

```json
"dependencies": {
  "@sap/cds": "^9",
  "express": "^4",
  "read-excel-file": "^6.0.1"
},
"devDependencies": {
  "@cap-js/sqlite": "^2",
  "cds-plugin-ui5": "^0.13.0"
}
```

Install with:
```bash
npm install read-excel-file
```

`cds-plugin-ui5` + `workspaces: ["app/*"]` + `sapux: [...]` in `package.json` is what lets `cds watch` auto-serve both Fiori apps without a separate build step.

---

## 6. Fiori Elements Apps (generated in BAS)

Both generated the same way: **BAS → Fiori Application Generator → List Report Page V4 → Local CAP service (`board-games-handler`)**.

| App | Main entity | Purpose |
|---|---|---|
| `file-upload` | `Files` | Upload the `.xlsx` |
| `board-games` | `BoardGames` | View parsed/processed rows |

`app/services.cds` just pulls both apps' annotation files together:
```cds
using from './board-games/annotations';
using from './file-upload/annotations';
```

UI annotations (`UI.LineItem`, `UI.FieldGroup`, `UI.Facets`) in each app's `annotations.cds` are mostly generator boilerplate — map each field to a label for list columns / object page.

Run each app individually via the npm scripts:
```bash
npm run watch-board-games   # opens boardgames/index.html
npm run watch-file-upload   # opens fileupload/index.html
```

---

## 7. Test Flow

1. `cds watch` (or one of the `watch-*` scripts above).
2. Open the **file-upload** app → create a new `Files` record → attach your test `.xlsx` (columns: `Name, Price, Players, PlayTimeMinutes, AgeRating`).
3. Save → `CREATE` handler on `Files` fires → parses rows → inserts into `BoardGames` (price doubled as demo business rule).
4. Open the **board-games** app → confirm rows appear with transformed prices.

---

## 8. Gotchas / Things to double check while rebuilding

- Column **order** in the Excel file must match the destructuring order in the handler — no header-name matching is done, it's positional.
- `@Core.AcceptableMediaTypes` only allows the real `.xlsx` MIME type (`application/vnd.openxmlformats-officedocument.spreadsheetml.sheet`) — `.xls` (old binary format) will be rejected.
- Forgetting `@odata.draft.enabled` on `Files` breaks the upload control's create flow on the Object Page.
- Forgetting `return next()` in the handler means the `Files` row itself never gets generically persisted.
- `read-excel-file/node` (not the plain browser import) is required server-side in Node.js.
