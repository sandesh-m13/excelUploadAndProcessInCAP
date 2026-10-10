using BoardGamesHandler as service from '../../srv/bg-srv';

annotate service.BoardGames with @(
    UI.FieldGroup #GeneratedGroup: {
        $Type                              : 'UI.FieldGroupType',
        Data                               : [
            {
                $Type: 'UI.DataField',
                Label: 'name',
                Value: name,
            },
            {
                $Type: 'UI.DataField',
                Label: 'price',
                Value: price,
            },
            {
                $Type: 'UI.DataField',
                Label: 'players',
                Value: players,
            },
            {
                $Type: 'UI.DataField',
                Label: 'playTimeMinutes',
                Value: playTimeMinutes,
            },
            {
                $Type: 'UI.DataField',
                Label: 'ageRating',
                Value: ageRating,
            },
            {
                $Type     : 'UI.DataField',
                Value     : under60Min,
                Label     : 'Game Time Issue',
                @UI.Hidden: {$edmJson: {$Not: [{$Path: 'isbelow60'}]}}, //virtual field based hiding
            },
        ],
        Common.SideEffects #PlayTimeChanges: { //sideeffect to update field automatically without app refresh
            $Type           : 'Common.SideEffectsType',
            SourceProperties: 'playTimeMinutes',
            //we can pass source entities, events as well
            SourceEntities: 'BoardGames',
            TargetProperties: 'under60Min',
        //we can pass target entitied as well to update


        },
    },
    UI.Facets                    : [{
        $Type : 'UI.ReferenceFacet',
        ID    : 'GeneratedFacet1',
        Label : 'General Information',
        Target: '@UI.FieldGroup#GeneratedGroup',
    }, ],
    UI.LineItem                  : [
        {
            $Type: 'UI.DataField',
            Label: 'name',
            Value: name,
        },
        {
            $Type: 'UI.DataField',
            Label: 'price',
            Value: price,
        },
        {
            $Type: 'UI.DataField',
            Label: 'players',
            Value: players,
        },
        {
            $Type: 'UI.DataField',
            Label: 'playTimeMinutes',
            Value: playTimeMinutes,
        },
        {
            $Type: 'UI.DataField',
            Label: 'ageRating',
            Value: ageRating,
        },
    ],
);

