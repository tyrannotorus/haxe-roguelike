package com.roguelike.dialogs;

import openfl.display.Bitmap;
import openfl.display.Sprite;
import com.roguelike.Matte;
import com.roguelike.MatteData;
import com.roguelike.TextData;
import com.roguelike.managers.TextManager;

/**
 * GenericDialog.hx.
 * - A sized generic dialog.
 */
class GenericDialog extends Sprite {

	private var headerContainer:Sprite;
	private var headerText:Bitmap;
	
	/**
	 * Constructor.
	 * @param {DialogData} dialogData
	 */
	public function new(dialogData:DialogData = null) {
		
		super();
		
		if (dialogData == null) {
			dialogData = new DialogData();
		}
		
		// Create the backing matte for the dialog.
		var tilesBackground:Sprite = Matte.toSprite(dialogData);
		addChild(tilesBackground);
		
		// Create the header and header backing matte.
		var headerData:MatteData = new MatteData();
		headerData.width = dialogData.width;
		headerData.height = dialogData.headerHeight;
		headerData.topRadius = dialogData.topRadius;
		headerData.bottomRadius = 0;
		headerData.borderColor = dialogData.headerBorderColor;
		headerData.matteColor = dialogData.headerMatteColor;
		headerContainer = Matte.toSprite(headerData);
		headerContainer.buttonMode = true;
		addChild(headerContainer);
		
		// Create the header text data.
		var textObject:TextData = new TextData();
		textObject.text = dialogData.headerText;
		textObject.upColor = dialogData.headerTextColor;
		textObject.shadowColor = dialogData.headerTextShadowColor;
		
		// Add the header text.
		headerText = TextManager.getInstance().toBitmap(textObject);
		headerText.y = 3;
		headerText.x = 4;
		headerContainer.addChild(headerText);
	}
}