package decorators;

import java.awt.*;

import drawingTools.LocatedRectangle;
import kangaroo.Kangaroo;

public class FaceColorDecorator extends KangarooDecorator {
    private Color faceColor; // Face object to be decorated

    public FaceColorDecorator(LocatedRectangle kangaroo, Color faceColor) {
        super(kangaroo);
        this.faceColor = faceColor; // Initialize the Face object
    }

    //FaceColorDecorator overrides draw() from LocatedRectangle (via KangarooDecorator).
    @Override
    public void draw() {
    	LocatedRectangle current = decorated;	// decorated variable is coming (inherited) from the super class KangarooDecorator

        while (!(current instanceof Kangaroo)) {
        	current = ((KangarooDecorator) current).getPreviousStageOfKangaroo();
        }
        ((Kangaroo) current).setFaceColor(faceColor);
        decorated.draw();

    }
    @Override
    public int width() {
        return decorated.width();
    }
    @Override
    public int height() {
        return decorated.height();
    }
    @Override
    public Point address() {
        return decorated.address();
    }

}

