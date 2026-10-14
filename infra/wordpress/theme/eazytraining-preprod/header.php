<!doctype html>
<html <?php language_attributes(); ?>>
<head>
  <meta charset="<?php bloginfo('charset'); ?>">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <?php wp_head(); ?>
</head>
<body <?php body_class(); ?>>
<?php wp_body_open(); ?>
<header class="site-header">
  <div class="container nav-wrap">
    <a class="brand" href="<?php echo esc_url(home_url('/')); ?>">
      <span class="brand-mark" aria-hidden="true">E</span>
      <span class="brand-copy"><strong><?php bloginfo('name'); ?></strong><small>Impact & solidarité</small></span>
    </a>
    <button class="nav-toggle" type="button" aria-label="Afficher le menu" onclick="document.body.classList.toggle('menu-open')">☰</button>
    <nav class="main-nav" aria-label="Navigation principale">
      <?php
      wp_nav_menu([
          'theme_location' => 'primary',
          'container' => false,
          'fallback_cb' => false,
          'menu_class' => 'menu',
      ]);
      ?>
      <a class="nav-donate" href="<?php echo esc_url(home_url('/faire-un-don/')); ?>">Faire un don</a>
    </nav>
  </div>
</header>
<main>
