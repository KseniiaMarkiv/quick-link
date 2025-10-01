// Options flyout (click to toggle; click outside/Esc to close)
document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('.options-toggle').forEach((btn) => {
    btn.addEventListener('click', (e) => {
      e.preventDefault();
      const wrap = btn.closest('.options-menu');
      document.querySelectorAll('.options-menu.is-open').forEach((w) => { if (w !== wrap) w.classList.remove('is-open'); });
      wrap.classList.toggle('is-open');
    });
  });

  document.addEventListener('click', (e) => {
    if (!e.target.closest('.options-menu')) {
      document.querySelectorAll('.options-menu.is-open').forEach((w) => w.classList.remove('is-open'));
    }
  });

  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      document.querySelectorAll('.options-menu.is-open').forEach((w) => w.classList.remove('is-open'));
    }
  });
});

// Generic confirm for any form with data-turbo-confirm or data-confirm
(function () {
  document.addEventListener('submit', function (e) {
    const form = e.target;
    if (!(form instanceof HTMLFormElement)) return;

    const msg = form.dataset.turboConfirm || form.dataset.confirm;
    if (!msg) return;

    if (!window.confirm(msg)) {
      e.preventDefault();
      e.stopImmediatePropagation();
    }
  }, true); // capture phase to intercept before submit proceeds
})();
