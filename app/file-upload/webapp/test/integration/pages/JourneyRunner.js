sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"fileupload/test/integration/pages/FilesList.gen",
	"fileupload/test/integration/pages/FilesObjectPage.gen"
], function (JourneyRunner, FilesListGenerated, FilesObjectPageGenerated) {
    'use strict';

    const runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('fileupload') + '/test/flp.html#app-preview',
        pages: {
			onTheFilesListGenerated: FilesListGenerated,
			onTheFilesObjectPageGenerated: FilesObjectPageGenerated
        },
        async: true
    });

    return runner;
});

