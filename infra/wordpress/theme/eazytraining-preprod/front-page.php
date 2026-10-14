<?php get_header();
$first_form_id = function_exists('eazyimpact_first_form_id') ? eazyimpact_first_form_id() : 0;
$form_count = function_exists('eazyimpact_total_forms') ? eazyimpact_total_forms() : 0;
?>
<section class="hero-impact">
  <div class="container hero-grid">
    <div class="hero-content">
      <span class="eyebrow-pill">ENSEMBLE, NOUS POUVONS AGIR</span>
      <h1>Chaque geste peut devenir <em>une vraie chance.</em></h1>
      <p class="hero-lead">Soutenez des projets concrets, suivez leur progression et participez à une communauté qui transforme la générosité en impact durable.</p>
      <div class="hero-actions">
        <a class="btn btn-primary" href="<?php echo esc_url(home_url('/faire-un-don/')); ?>">Soutenir une action</a>
        <a class="btn btn-ghost" href="<?php echo esc_url(home_url('/nos-campagnes/')); ?>">Voir les campagnes</a>
      </div>
      <div class="trust-row">
        <span>✓ Dons sécurisés</span>
        <span>✓ Suivi transparent</span>
        <span>✓ Reçus disponibles</span>
      </div>
    </div>
    <div class="hero-visual" aria-label="Illustration solidaire">
      <div class="orb orb-one"></div><div class="orb orb-two"></div>
      <div class="impact-card main-card">
        <div class="impact-icon">♥</div>
        <span>Notre mission</span>
        <h3>Transformer la solidarité en actions mesurables.</h3>
        <div class="mini-progress"><i></i></div>
        <div class="card-meta"><b><?php echo esc_html(max(1, $form_count)); ?></b><small>campagne<?php echo $form_count > 1 ? 's' : ''; ?> active<?php echo $form_count > 1 ? 's' : ''; ?></small></div>
      </div>
      <div class="floating-card fc-one"><strong>100%</strong><small>engagement</small></div>
      <div class="floating-card fc-two"><span>↗</span><strong>Impact</strong><small>qui grandit</small></div>
    </div>
  </div>
</section>

<section class="section intro-section">
  <div class="container centered-heading">
    <span class="section-kicker">NOS PRIORITÉS</span>
    <h2>Des causes concrètes, une plateforme simple.</h2>
    <p>Découvrez les initiatives soutenues par notre communauté et choisissez celle qui vous parle le plus.</p>
  </div>
  <div class="container cards-grid">
    <article class="cause-card"><div class="cause-icon">✦</div><h3>Éducation</h3><p>Donner aux jeunes l'accès aux outils, aux compétences et aux opportunités qui ouvrent des portes.</p><a href="<?php echo esc_url(home_url('/nos-campagnes/')); ?>">Découvrir →</a></article>
    <article class="cause-card"><div class="cause-icon">♡</div><h3>Santé & bien-être</h3><p>Contribuer à des initiatives qui améliorent l'accès aux soins et accompagnent les personnes fragiles.</p><a href="<?php echo esc_url(home_url('/nos-campagnes/')); ?>">Découvrir →</a></article>
    <article class="cause-card"><div class="cause-icon">⌂</div><h3>Communautés</h3><p>Soutenir des projets locaux à impact direct, portés au plus près des besoins des bénéficiaires.</p><a href="<?php echo esc_url(home_url('/notre-impact/')); ?>">Voir l'impact →</a></article>
  </div>
</section>

<section class="section campaigns-preview">
  <div class="container section-head-inline"><div><span class="section-kicker">CAMPAGNES</span><h2>Les actions à soutenir maintenant.</h2></div><a class="text-link" href="<?php echo esc_url(home_url('/nos-campagnes/')); ?>">Toutes les campagnes →</a></div>
  <div class="container give-zone">
    <?php
    if (shortcode_exists('give_form_grid')) {
        echo do_shortcode('[give_form_grid columns="3" show_goal="true" show_excerpt="true" forms_per_page="3"]');
    } else {
        echo '<div class="empty-state"><strong>Les campagnes seront bientôt disponibles.</strong><p>Le module de collecte est en cours de préparation.</p></div>';
    }
    ?>
  </div>
</section>

<section class="section impact-strip">
  <div class="container impact-grid">
    <div><span class="section-kicker light">TRANSPARENCE</span><h2>Votre générosité mérite de la visibilité.</h2><p>Grâce à GiveWP, les donateurs peuvent retrouver leur historique, leurs reçus et les campagnes auxquelles ils ont contribué.</p><a class="btn btn-light" href="<?php echo esc_url(home_url('/espace-donateur/')); ?>">Accéder à mon espace</a></div>
    <div class="impact-numbers"><div><strong>01</strong><span>Choisir une cause</span></div><div><strong>02</strong><span>Faire un don</span></div><div><strong>03</strong><span>Suivre son impact</span></div></div>
  </div>
</section>

<section class="section final-cta">
  <div class="container cta-box">
    <div><span class="section-kicker">AGIR MAINTENANT</span><h2>Une contribution, petite ou grande, peut faire la différence.</h2></div>
    <a class="btn btn-primary" href="<?php echo esc_url(home_url('/faire-un-don/')); ?>">Je fais un don</a>
  </div>
</section>
<?php get_footer(); ?>
