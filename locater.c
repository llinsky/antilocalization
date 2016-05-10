//locater.c

/*
 * Copyright (c) 2007, Swedish Institute of Computer Science.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the Institute nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE INSTITUTE AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE INSTITUTE OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 *
 */

/**
 * \file
 *         Locate a spoofing transmitter using a gradient finding algorithm
 * \authors
            Leo Linsky
            Tim Ferrell
 */

#include "contiki.h"
#include "net/rime.h"
#include "random.h"

#include "net/netstack.h"

#include "cc2420.h"
#include "cc2420_const.h"
#include "dev/spi.h"

#include "dev/button-sensor.h"

#include "dev/leds.h"

#include <stdio.h>
#include <string.h>


#define SKIP_NUMBER 10

#define RSSI_HISTORY 20

#define WAIT_TIME 5

#define STEP_SIZE 1 //we will do our best to approximate this -- it's irrelevant in this code

/*
enum directions_t
{
	S = 0,
	SW = 1,
	W = 2,
	NW = 3,
	N = 4,
	NE = 5,
	E = 6,
	SE = 7,
}

*/

/*---------------------------------------------------------------------------*/
PROCESS(example_broadcast_process, "Broadcast example");
AUTOSTART_PROCESSES(&example_broadcast_process);
/*---------------------------------------------------------------------------*/

static int skip = 0;
static int wait = WAIT_TIME;
//static int last_rssi[RSSI_HISTORY];
static int rssi_last = 0;
static int direction = 0;

static int sum = 0;
static int true_rssi = 0;

static int steps_taken = 0;

static void
broadcast_recv(struct broadcast_conn *c, const rimeaddr_t *from)
{
  //printf("\nbroadcast message received from %d.%d: \n'%s'\n",
//         from->u8[0], from->u8[1], (char *)packetbuf_dataptr());

  skip++;

  //Ignoring pkt_id, interested in rssi
  int rssi = packetbuf_attr(PACKETBUF_ATTR_RSSI);

  printf("\nRx rssi value = %d \n", rssi);

  sum += rssi;

  //Number of measurements before we make a decision
  if (skip%SKIP_NUMBER == 0)
  {
  	true_rssi = sum/SKIP_NUMBER;

  	skip = 0;
  	sum = 0;

  }
  else
  {
  	return;
  }


  /*
  int rssi = packetbuf_attr(PACKETBUF_ATTR_RSSI);

  printf("Rx rssi value = %d \n", rssi);

  int i;
  for (i=(RSSI_HISTORY-2);i>=0;i--)
  {
  	last_rssi[i+1] = last_rssi[i];
  }
  last_rssi[0] = rssi;


  int sum_recent = 0;
  int sum_old = 0;
  for (i=0;i<RSSI_HISTORY;i++)
  {
  	if (i > RSSI_HISTORY/2)
  	{
  		sum_recent = sum_recent + last_rssi[i];
  	}
  	else
  	{
  		sum_old = sum_old + last_rssi[i];
  	}
  }
  

  wait = wait - 1;

  if (wait <= 0)
  {
  	wait = WAIT_TIME;
  }
  else
  {
  	return;
  }

  */



  if (true_rssi < rssi_last)
  {
  	//tumble
  	printf(". . .Tumbling . . . \n");

  	direction = random_rand() % 8;
  }

  printf("Step number %d: \t",++steps_taken);

  switch (direction)
  {
  	case 0:
  		printf("Walk South!\n");
  		break;
  	case 1:
  		printf("Walk SouthWest!\n");
  		break;
  	case 2:
  		printf("Walk West!\n");
  		break;
  	case 3:
  		printf("Walk NorthWest!\n");
  		break;
  	case 4:
  		printf("Walk North!\n");
  		break;
  	case 5:
  		printf("Walk NorthEast!\n");
  		break;
  	case 6:
  		printf("Walk East!\n");
  		break;
  	case 7:
  		printf("Walk SouthEast!\n");
  		break;
  	default:
  		printf("\nJump!\n");
  		break;
  }
  
  rssi_last = true_rssi;
}


static const struct broadcast_callbacks broadcast_call = {broadcast_recv};
static struct broadcast_conn broadcast;




/*---------------------------------------------------------------------------*/
PROCESS_THREAD(example_broadcast_process, ev, data)
{
  static struct etimer et;

  PROCESS_EXITHANDLER(broadcast_close(&broadcast);)

  PROCESS_BEGIN();

  broadcast_open(&broadcast, 129, &broadcast_call);

  //int txpower = 0;

  char buf[50];

  while(1) {

    /* Delay 2-4 seconds */
    //etimer_set(&et, CLOCK_SECOND * 4 + random_rand() % (CLOCK_SECOND * 4));
    etimer_set(&et, 30*CLOCK_SECOND);

    PROCESS_WAIT_EVENT_UNTIL(etimer_expired(&et));

    //memset(last_rssi,0,sizeof(int)*RSSI_HISTORY);

    //cc2420_get_txpower();
    //CC2420_TXPOWER_MAX  

    //txpower = 1+random_rand()%CC2420_TXPOWER_MAX;
    //cc2420_set_txpower(txpower);

    sprintf(buf, "Seeking intruder. I will find you eventually.\n");

    packetbuf_copyfrom(buf,50);
    broadcast_send(&broadcast);



    printf("broadcast message sent \n");
  }

  PROCESS_END();
}
