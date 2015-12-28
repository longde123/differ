package states;

import luxe.Vector;
import luxe.Input;
import luxe.Color;

import differ.Collision;
import differ.math.Vector in V;
import differ.shapes.*;
import differ.data.*;

class Polygons extends luxe.States.State {

    var fixed : Array<Shape>;
    var mover : Shape;
    var moverA : Polygon;
    var moverB : Circle;
    var toggle : Bool = false;
    var colors : Array<Color>;

    override function onenter<T>(_:T) {

        colors = [ new Color(1,1,1,0.5), new Color(1,1,1,0.5).rgb(0x007bf6) ];

        fixed = [
            Polygon.triangle(100, Luxe.screen.mid.y, 50),
            Polygon.rectangle(300, Luxe.screen.mid.y, 100, 60),
            Polygon.create(500, Luxe.screen.mid.y, 5, 50),
            Polygon.create(600, Luxe.screen.mid.y, 8, 50),
            new Circle(400, Luxe.screen.mid.y, 40),
        ];


        moverA = Polygon.square(10, 100, 50);
        moverB = new Circle(10, 100, 30);
        mover = moverA;

        for(fix in fixed) Main.shapes.push(fix);
        Main.shapes.push(moverA);
        Main.shapes.push(moverB);

        var text =  '\nThe white polygon is the position the separation would result in.\n';
            text += 'Hold down left or right mouse to rotate the box.';

        Main.display(text);

    } //onenter

    override function onleave<T>(_:T) {

        for(fix in fixed) fix.destroy();
        fixed = null;

        mover.destroy();
        mover = null;

    } //onleave


    override function onkeyup(e:KeyEvent) {
        if(e.keycode == Key.key_m) {
            toggle = !toggle;
            if(toggle) {
                mover = moverB; 
            } else {
                mover = moverA;
            }
        }
    }

    override function onmousemove(e:MouseEvent) {

        mover.position = new V(e.pos.x, e.pos.y);

    } //onmousemove

    override function onrender() {

        if( Luxe.input.mousedown(MouseButton.left) ) {
            mover.rotation += 50 * Luxe.dt;
        }

        if( Luxe.input.mousedown(MouseButton.right) ) {
            mover.rotation -= 50 * Luxe.dt;
        }

        var collisions = Collision.shapeWithShapes(mover, fixed);

        if(collisions.length == 0) return;

        var index = 0;
        for(coll in collisions) {

            Main.drawer.drawShapeCollision(coll);

            //draw a ghost shape where the collision would resolve to
            //we do that by using the separation data, and add it to the "shape1"
            //position, above, that shape1 is mover

            var r : phoenix.geometry.Geometry;

            if(toggle) {
                r = Luxe.draw.ring({
                    immediate: true,
                    color: colors[index],
                    batcher: Main.thicker,
                    x: coll.shape1.position.x + coll.separationX,
                    y: coll.shape1.position.y + coll.separationY,
                    r: 30
                });
            } else {
                r = Luxe.draw.rectangle({
                    immediate: true,
                    color: colors[index],
                    batcher: Main.thicker,
                    x: coll.shape1.position.x + coll.separationX,
                    y: coll.shape1.position.y + coll.separationY,
                    w: 50, h: 50,
                    origin: new Vector(25,25)
                });
            }

            var rot_radians = luxe.utils.Maths.radians(mover.rotation);
            r.transform.rotation.setFromEuler(new Vector(0,0,rot_radians));

            index++;

        }

    }

}
