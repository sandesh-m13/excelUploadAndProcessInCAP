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

      for (const entry of entries) await INSERT.into(BoardGames).entries(entry);
      req.info('Boardgames created from CSV!')            //infoormation popup
      // req.notify('Boardgames created from CSV!')         //messagetoast but when combined with other types of messages it shoes up as success in big popup
      // req.warn('Boardgames created from CSV!')           //shows as popup as warning
      // req.error('Boardgames created from CSV!')       //error overrrides all the previous execution and messages to UI and only shows error message


      return next();      //for .on handler returning next() is imp because we are overriding the standard flow.
    })

    this.after('READ', BoardGames, async (boardgames) => {  //enabling under60Min field if gametime is below 60 min
      for (const boardgame of boardgames) {
        boardgame.isbelow60 = boardgame.playTimeMinutes < 60;  //setting true/false to virtual field
      }
    })

    //Updating fields dynamically after user input - if user edits gametime and makes it greater than 60 we will update under60Min field

    this.before('UPDATE', 'BoardGames.drafts', async (req) => {
      //reason for using drafts as entity is to update the field under60min field dynamically in the draft screen itself
      if (req.data.playTimeMinutes >= 60) {
        req.data.under60Min = 'Game time 60 mins or more'
        req.data.isbelow60 = false;  //setting it to false as this will disable the under60min field

      } else {
        req.data.under60Min = 'Game time less than 60 mins' // also making this field read only so that user cannot enter any random value
        req.data.isbelow60 = true;  
      }
    })

    return super.init()
  }
}
