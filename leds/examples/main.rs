extern crate prusst;
extern crate leds;

use prusst::{Pruss, IntcConfig};

use leds::{Leds, Rgbw};

use std::iter;

fn main() {
    let mut pruss = Pruss::new(&IntcConfig::new_populated()).unwrap();
    let mut leds = Leds::init(&mut pruss).unwrap();
    // let strand = [
        // Rgbw::new(255, 0, 0, 0),
        // Rgbw::new(0, 255, 0, 0),
        // Rgbw::new(0, 0, 255, 0),
        // Rgbw::new(0, 0, 0, 255),
        // Rgbw::new(255, 240, 200, 255),
        // Rgbw::new(255, 240, 200, 255),
        // Rgbw::new(255, 240, 200, 255),
        // Rgbw::new(255, 240, 200, 255),
        // Rgbw::new(255, 240, 200, 255),
        // Rgbw::new(255, 240, 200, 255),
        // Rgbw::new(255, 240, 200, 255),
        // Rgbw::new(255, 240, 200, 255),
        // Rgbw::new(0, 0, 0, 0),
        // Rgbw::new(0, 0, 0, 0),
        // Rgbw::new(0, 0, 0, 0),
        // Rgbw::new(0, 0, 0, 0),
        // Rgbw::new(0, 0, 0, 0),
        // Rgbw::new(0, 0, 0, 0),
        // Rgbw::new(0, 0, 0, 0),
        // Rgbw::new(0, 0, 0, 0),
    // ];
    // let strand = iter::repeat(Rgbw::new(0, 0, 0, 20)).take(240).collect::<Vec<_>>();
    let strand = iter::repeat(Rgbw::new(0, 0, 0, 0)).take(240).collect::<Vec<_>>();
    println!("going to write leds: {:?}", &strand[..]);
    leds.write_leds(&strand[..]);
    println!("leds written!");
}
