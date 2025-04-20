import {
  ifDevice,
  map,
  layer,
  toApp,
  rule,
  writeToProfile,
} from 'karabiner.ts'

function main() {
  writeToProfile(
    'Default',
    [
      arrow_keys(),
      keyboard_apple(),
    ],
    {
      'basic.simultaneous_threshold_milliseconds': 50,
      'duo_layer.threshold_milliseconds': 50,
      'duo_layer.notification': true,
    },
  )
}

function arrow_keys() {
  return layer('⇥', 'launch-app').manipulators({
    b: toApp('Zen'),
    c: toApp('Calendar'),
    f: toApp('Finder'),
    s: toApp('Slack'),
    e: toApp('Mail'),
    t: toApp('Ghostty'),
  })
}


function keyboard_apple() {
  let ifAppleKeyboard = ifDevice({ vendor_id: 12951 }).unless() // Not Moonlander
  return rule('Apple Keyboard', ifAppleKeyboard).manipulators([
    map('‹⌘').to('‹⌘').toIfAlone('⎋'),
    map('›⇧').toMeh(),
    map('⇥').toHyper().toIfAlone('⇥'),
    map('⇪').to('‹⌃').toIfAlone('⇥', '‹⌘'),
  ])
}

main()
