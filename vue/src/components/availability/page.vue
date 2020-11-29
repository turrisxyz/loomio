<script lang="coffee">
import AppConfig      from '@/shared/services/app_config'
import Session        from '@/shared/services/session'
import Records        from '@/shared/services/records'
import EventBus       from '@/shared/services/event_bus'
import AbilityService from '@/shared/services/ability_service'
import LmoUrlService  from '@/shared/services/lmo_url_service'
import openModal      from '@/shared/helpers/open_modal'
import UserService    from '@/shared/services/user_service'
import Flash   from '@/shared/services/flash'

export default
  data: ->
    user: null
    icalUrl: ''
    dialogOpen: false

  created: ->
    EventBus.$emit 'currentComponent', { titleKey: 'availability.my_availability', page: 'availabilityPage'}
    EventBus.$on 'signedIn', @init

  beforeDestroy: ->
    EventBus.$off 'signedIn', @init

  methods:
    submit: ->
      @loading = true
      Records.calendarEvents.remote.post('import_ical', url: @icalUrl).then =>
        @loading = false
        @dialogOpen = false

    init: ->
      nothing = 1

</script>
<template lang="pug">
v-main
  v-container.profile-page.max-width-1024
    v-dialog(v-model="dialogOpen")
      template(v-slot:activator="{on, attrs}")
        v-btn(v-bind="attrs" v-on="on") Add ICal URL
      v-card
        v-card-title.headline Add iCal
        v-card-text
          p grab the 'secret address in ical format' from google calendar and enter it here
          p we'll do add via google api later.
          p we'll refresh this once a day
          v-text-field(v-model="icalUrl" label="iCalendar url" placeholder="https://calendar.google.com/something.ics")
        v-card-actions
          v-spacer
          v-btn(@click="submit" :loading="loading" :disabled="icalUrl.length == 0") Import

    p good news, you're free
    v-btn google sync
    v-btn outlook sync
    p click and drag to add free or busy times
    //-don't show event names to other people.
    //- p when adding time, it asks if free or busy, and if it repeats, how often
    v-calendar
</template>

<style lang="sass">
</style>
