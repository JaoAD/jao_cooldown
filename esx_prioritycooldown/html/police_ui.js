document.addEventListener('DOMContentLoaded', () => {
  const policePanel = document.getElementById('police-panel');
  const safeBtn = document.getElementById('safe-btn');
  const cooldownBtn = document.getElementById('cooldown-btn');
  const inProgressBtn = document.getElementById('inprogress-btn');
  const resetPcdBtn = document.getElementById('resetpcd-btn');
  const closeBtn = document.getElementById('close-btn');

  function postData(action) {
    fetch(`https://${GetParentResourceName()}/action`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: JSON.stringify({ action: action }),
    });
  }

  safeBtn.addEventListener('click', () => postData('safe'));
  cooldownBtn.addEventListener('click', () => postData('cooldown'));
  inProgressBtn.addEventListener('click', () => postData('inprogress'));
  resetPcdBtn.addEventListener('click', () => postData('resetpcd'));
  closeBtn.addEventListener('click', () => {
    policePanel.classList.add('hidden');
    fetch(`https://${GetParentResourceName()}/close`, { method: 'POST' });
  });

  window.addEventListener('message', (event) => {
    if (event.data.type === 'openUI') {
      policePanel.classList.remove('hidden');
    }
  });
});
