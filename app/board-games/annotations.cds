using BoardGamesHandler as service from '../../srv/bg-srv';
annotate service.BoardGames with @(
    UI.FieldGroup #GeneratedGroup : {
        $Type : 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Label : 'name',
                Value : name,
            },
            {
                $Type : 'UI.DataField',
                Label : 'price',
                Value : price,
            },
            {
                $Type : 'UI.DataField',
                Label : 'players',
                Value : players,
            },
            {
                $Type : 'UI.DataField',
                Label : 'playTimeMinutes',
                Value : playTimeMinutes,
            },
            {
                $Type : 'UI.DataField',
                Label : 'ageRating',
                Value : ageRating,
            },
        ],
    },
    UI.Facets : [
        {
            $Type : 'UI.ReferenceFacet',
            ID : 'GeneratedFacet1',
            Label : 'General Information',
            Target : '@UI.FieldGroup#GeneratedGroup',
        },
    ],
    UI.LineItem : [
        {
            $Type : 'UI.DataField',
            Label : 'name',
            Value : name,
        },
        {
            $Type : 'UI.DataField',
            Label : 'price',
            Value : price,
        },
        {
            $Type : 'UI.DataField',
            Label : 'players',
            Value : players,
        },
        {
            $Type : 'UI.DataField',
            Label : 'playTimeMinutes',
            Value : playTimeMinutes,
        },
        {
            $Type : 'UI.DataField',
            Label : 'ageRating',
            Value : ageRating,
        },
    ],
);

