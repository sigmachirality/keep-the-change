import type { PlasmoMessaging } from "@plasmohq/messaging"
import { Storage } from "@plasmohq/storage"

const storage = new Storage()

const handler: PlasmoMessaging.MessageHandler = async (req, res) => {
  const message = req.body;
  await storage.set("message", message);
  await chrome.windows.create({
    url: '/tabs/donate-prompt.html',
    type: 'popup',
    width: 375,
    height: 600,
    focused: true
  })
  res.send({});
}

export default handler