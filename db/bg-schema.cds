using cuid from '@sap/cds/common';

namespace bg;

entity BoardGames : cuid {
    name            : String(120);
    price           : Decimal(15, 2);
    players         : String(20);
    playTimeMinutes : Integer;
    ageRating       : String(10);
    under60Min        : String default 'Game time less than 60 mins'
}

entity Files : cuid {
    fileName : String(260);
    fileType : String      @Core.IsMediaType;
    content  : LargeBinary @Core.MediaType                  : fileType
                           @Core.AcceptableMediaTypes       : ['application/vnd.openxmlformats-officedocument.spreadsheetml.sheet']
                           @Core.ContentDisposition.Filename: fileName
}
