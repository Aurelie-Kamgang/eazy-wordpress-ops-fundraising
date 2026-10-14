</main>
<footer class="site-footer">
  <div class="container footer-grid">
    <div>
      <div class="footer-brand"><span class="brand-mark small">E</span><strong><?php bloginfo('name'); ?></strong></div>
      <p>Une plateforme de collecte solidaire propulsée par WordPress et GiveWP.</p>
    </div>
    <div>
      <h4>Découvrir</h4>
      <a href="<?php echo esc_url(home_url('/nos-campagnes/')); ?>">Nos campagnes</a>
      <a href="<?php echo esc_url(home_url('/notre-impact/')); ?>">Notre impact</a>
      <a href="<?php echo esc_url(home_url('/a-propos/')); ?>">À propos</a>
    </div>
    <div>
      <h4>Donateurs</h4>
      <a href="<?php echo esc_url(home_url('/espace-donateur/')); ?>">Espace donateur</a>
      <a href="<?php echo esc_url(home_url('/faire-un-don/')); ?>">Faire un don</a>
      <a href="<?php echo esc_url(admin_url()); ?>">Administration</a>
    </div>
  </div>
  <div class="container footer-bottom">
    <span>© <?php echo esc_html(date('Y')); ?> <?php bloginfo('name'); ?></span>
    <span>Environnement de préproduction</span>
  </div>
</footer>
<?php wp_footer(); ?>
</body>
</html>
