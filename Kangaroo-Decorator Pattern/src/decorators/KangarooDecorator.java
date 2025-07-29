package decorators;
import java.awt.Point;

import drawingTools.LocatedRectangle;

// Decorator base
public abstract class KangarooDecorator implements LocatedRectangle {
    protected LocatedRectangle decorated;

    public KangarooDecorator(LocatedRectangle decorated) {
        this.decorated = decorated;
    }
    
    public LocatedRectangle getPreviousStageOfKangaroo() {
        return decorated;
    }
}