using {bg} from '../db/bg-schema';

service BoardGamesHandler {
    entity BoardGames as projection on bg.BoardGames;
    entity Files as projection on bg.Files;

}

annotate BoardGamesHandler.Files with @odata.draft.enabled;

