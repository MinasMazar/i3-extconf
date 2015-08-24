
include Clockwork

every 7.minute, 'xscreensaver-deactivator' do
  `xscreensaver-command -deactivate`
end

