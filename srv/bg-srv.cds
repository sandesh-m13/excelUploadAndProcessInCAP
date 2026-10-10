using {bg} from '../db/bg-schema';

service BoardGamesHandler {
    entity BoardGames as projection on bg.BoardGames{
        *,
        virtual isbelow60 : Boolean   //this virtual field helps in hiding and unhiding the fields
    };
    entity Files as projection on bg.Files;

}

annotate BoardGamesHandler.Files with @odata.draft.enabled;
annotate BoardGamesHandler.BoardGames with @odata.draft.enabled;

