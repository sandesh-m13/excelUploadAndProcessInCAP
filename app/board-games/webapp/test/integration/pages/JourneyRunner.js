sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"boardgames/test/integration/pages/BoardGamesList.gen",
	"boardgames/test/integration/pages/BoardGamesObjectPage.gen"
], function (JourneyRunner, BoardGamesListGenerated, BoardGamesObjectPageGenerated) {
    'use strict';

    const runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('boardgames') + '/test/flp.html#app-preview',
        pages: {
			onTheBoardGamesListGenerated: BoardGamesListGenerated,
			onTheBoardGamesObjectPageGenerated: BoardGamesObjectPageGenerated
        },
        async: true
    });

    return runner;
});

