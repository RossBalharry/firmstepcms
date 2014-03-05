<div class="content-block-user-custom">
  <?php //dpm($account); ?>
  <?php if (isset($account->image_custom)) print $account->image_custom; ?>
  <div class="user-custom"><span> You are logged in as <?php
print $user->mail;
?></span>
  <a class="user-custom-link" href="<?php print base_path(); ?>user" title="My Profile">My Profile</a> - <a class="user-custom-link" href="<?php print base_path(); ?>user/logout" title="Logout">Logout</a></div>
  
</div>
