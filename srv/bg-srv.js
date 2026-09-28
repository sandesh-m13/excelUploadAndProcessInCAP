import cds from '@sap/cds'
import { INSERT } from '@sap/cds/lib/ql/cds-ql.js'
import { readSheet } from 'read-excel-file/node'


export class BoardGamesHandler extends cds.ApplicationService {
  init() {

    const { BoardGames, Files } = cds.entities('BoardGamesHandler')

    this.on('CREATE', Files, async (req, next) => {
      console.log(req.data.content) // we will get excel content as stream and we have to convert it to buffer in order to attach/add it to another entity

      const chunks = [];
      for await (const chunk of req.data.content) chunks.push(chunk);

      const buffer = Buffer.concat(chunks);
      //now we can use buffer to read the data using plugin - read excel file from npm | npm install in terminal
      const rows = await readSheet(buffer);
      console.log(rows)
      //now structuring rows as json object to assign it to BoardGames entity
      const [header, ...body] = rows;
      const entries = body.map(([name, price, players, playTimeMinutes, ageRating]) => ({
        name,
        price: Number(price) * 2,   // example business rule
        players,
        playTimeMinutes: Number(playTimeMinutes),
        ageRating
      }));

      for(const entry of entries) await INSERT.into(BoardGames).entries(entry);
      return next();      //for .on handler returning next() is imp because we are overriding the standard flow.
    })

    return super.init()
  }
}
