package decorators;

import java.awt.*;
import drawingTools.LocatedRectangle;
import kangaroo.Kangaroo;

// If you want to see the difference between eye color change (with decorator pattern)
public class EyeColorDecorator extends KangarooDecorator {
    private Color eyeColor; // Eye object to be decorated

    public EyeColorDecorator(LocatedRectangle kangaroo, Color eyeColor) {
        super(kangaroo);
        this.eyeColor = eyeColor; // Initialize the eye object
    }

    //EyeColorDecorator overrides draw() from LocatedRectangle (via KangarooDecorator).
    @Override
    public void draw() {
        LocatedRectangle current = decorated;	// decorated variable is coming (inherited) from the super class KangarooDecorator
        while (!(current instanceof Kangaroo)) {    //while current is not an instance of Kangaroo.
            current = ((KangarooDecorator) current).getPreviousStageOfKangaroo();   // it casts current to KangarooDecorator and its getPreviousStageOfKangaroo() method that returns the previous stage.
        }
        ((Kangaroo) current).setEyeColor(eyeColor); // Set the eye color of the base Kangaroo object so that it will reflect
        decorated.draw();

//        this version is w/o reflecting the eye color in the draw method
//        if (decorated instanceof Kangaroo) {
//            ((Kangaroo) decorated).setEyeColor(eyeColor);
//        }
//        super.draw();
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
