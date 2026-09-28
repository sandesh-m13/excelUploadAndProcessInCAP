using BoardGamesHandler as service from '../../srv/bg-srv';
annotate service.Files with @(
    UI.FieldGroup #GeneratedGroup : {
        $Type : 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Label : 'fileName',
                Value : fileName,
            },
            {
                $Type : 'UI.DataField',
                Label : 'fileType',
                Value : fileType,
            },
            {
                $Type : 'UI.DataField',
                Label : 'content',
                Value : content,
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
            Label : 'fileName',
            Value : fileName,
        },
        {
            $Type : 'UI.DataField',
            Label : 'fileType',
            Value : fileType,
        },
        {
            $Type : 'UI.DataField',
            Label : 'content',
            Value : content,
        },
    ],
);

