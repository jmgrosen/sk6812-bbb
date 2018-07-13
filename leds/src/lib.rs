extern crate prusst;

use prusst::{Pruss, Evtout, Sysevt, Error, MemSegment, Intc};

use std::io::Cursor;
use std::mem;
use std::sync::atomic;

#[repr(C)]
#[derive(Clone, Copy, Debug)]
pub struct Rgbw {
    pub green: u8,
    pub red: u8,
    pub blue: u8,
    pub white: u8,
}

impl Rgbw {
    pub fn new(red: u8, green: u8, blue: u8, white: u8) -> Rgbw {
        Rgbw { red, green, blue, white }
    }
}

#[repr(u32)]
#[derive(Clone, Copy)]
enum LedCmd {
    Go,
}

#[repr(C)]
#[derive(Clone, Copy)]
struct LedControl {
    cmd: LedCmd,
    num_leds: u32,
    leds_data: *const Rgbw,
}

pub struct Leds<'a> {
    intc: &'a mut Intc,
    ctrl_segment: MemSegment<'a>,
    rest_segment: MemSegment<'a>,
}

impl<'a> Leds<'a> {
    pub fn init<'b: 'a>(pruss: &'a mut Pruss<'b>) -> Result<Leds<'a>, Error> {
        let &mut Pruss { ref mut intc, ref mut pru0, ref mut dram0, .. } = pruss;
        let (ctrl_segment, rest_segment) = dram0.split_at(mem::size_of::<LedControl>());
        let code = &include_bytes!("../../pru/sk6812rgbw.bin")[..];
        unsafe {
            pru0.load_code(&mut Cursor::new(code))?.run();
        }

        Ok(Leds { intc, ctrl_segment, rest_segment })
    }

    pub fn write_leds(&mut self, leds: &[Rgbw]) {
        let irq = self.intc.register_irq(Evtout::E0);

        let leds_data = self.rest_segment.begin() as *const Rgbw;
        let _leds_pru = self.rest_segment.alloc_slice(leds);
        let _ctrl = self.ctrl_segment.alloc(LedControl {
            cmd: LedCmd::Go,
            num_leds: leds.len() as u32,
            leds_data,
        });

        atomic::fence(atomic::Ordering::Release);
        // thread::sleep(time::Duration::from_millis(1000));

        self.intc.send_sysevt(Sysevt::S21);
        irq.wait();
        self.intc.clear_sysevt(Sysevt::S19);
    }
}
