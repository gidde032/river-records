-- CreateEnum
CREATE TYPE "HatchIntensity" AS ENUM ('light', 'moderate', 'heavy');

-- CreateEnum
CREATE TYPE "TimeOfDay" AS ENUM ('morning', 'midday', 'afternoon', 'evening');

-- CreateEnum
CREATE TYPE "FishingMethod" AS ENUM ('dry', 'nymph', 'streamer', 'wet', 'other');

-- CreateEnum
CREATE TYPE "ConditionType" AS ENUM ('gauge_height', 'discharge', 'temperature');

-- CreateEnum
CREATE TYPE "ThresholdOperator" AS ENUM ('above', 'below');

-- CreateTable
CREATE TABLE "River" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "state" TEXT NOT NULL,
    "description" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "River_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RiverSection" (
    "id" SERIAL NOT NULL,
    "river_id" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "usgs_site_code" TEXT NOT NULL,
    "latitude_start" DOUBLE PRECISION NOT NULL,
    "longitude_start" DOUBLE PRECISION NOT NULL,
    "latitude_end" DOUBLE PRECISION NOT NULL,
    "longitude_end" DOUBLE PRECISION NOT NULL,
    "target_species" TEXT[],
    "ideal_gauge_min" DOUBLE PRECISION,
    "ideal_gauge_max" DOUBLE PRECISION,
    "ideal_temp_min" DOUBLE PRECISION,
    "ideal_temp_max" DOUBLE PRECISION,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "RiverSection_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "StreamReading" (
    "id" SERIAL NOT NULL,
    "section_id" INTEGER NOT NULL,
    "gauge_height_ft" DOUBLE PRECISION NOT NULL,
    "discharge_cfs" DOUBLE PRECISION NOT NULL,
    "temperature_c" DOUBLE PRECISION,
    "reading_timestamp" TIMESTAMP(3) NOT NULL,
    "ingested_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "StreamReading_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "HatchReport" (
    "id" SERIAL NOT NULL,
    "user_id" TEXT NOT NULL,
    "section_id" INTEGER NOT NULL,
    "insect_species" TEXT NOT NULL,
    "intensity" "HatchIntensity" NOT NULL,
    "time_of_day" "TimeOfDay" NOT NULL,
    "report_date" TIMESTAMP(3) NOT NULL,
    "notes" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "HatchReport_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CatchLog" (
    "id" SERIAL NOT NULL,
    "user_id" TEXT NOT NULL,
    "section_id" INTEGER NOT NULL,
    "catch_date" TIMESTAMP(3) NOT NULL,
    "caught_species" TEXT NOT NULL,
    "method" "FishingMethod" NOT NULL,
    "fly_pattern" TEXT NOT NULL,
    "fly_size" INTEGER NOT NULL,
    "location_name" TEXT,
    "location_lat" DOUBLE PRECISION,
    "location_lng" DOUBLE PRECISION,
    "photo_url" TEXT,
    "notes" TEXT,
    "conditions_snapshot" JSONB NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "CatchLog_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Alert" (
    "id" SERIAL NOT NULL,
    "user_id" TEXT NOT NULL,
    "section_id" INTEGER NOT NULL,
    "condition_type" "ConditionType" NOT NULL,
    "operator" "ThresholdOperator" NOT NULL,
    "threshold_value" DOUBLE PRECISION NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "last_triggered_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Alert_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "StockingEvent" (
    "id" SERIAL NOT NULL,
    "section_id" INTEGER NOT NULL,
    "stocked_date" TIMESTAMP(3) NOT NULL,
    "species" TEXT NOT NULL,
    "quantity" INTEGER,
    "source_agency" TEXT NOT NULL,
    "source_url" TEXT,
    "ingested_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "StockingEvent_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "User" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "display_name" TEXT,
    "home_state" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- AddForeignKey
ALTER TABLE "RiverSection" ADD CONSTRAINT "RiverSection_river_id_fkey" FOREIGN KEY ("river_id") REFERENCES "River"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StreamReading" ADD CONSTRAINT "StreamReading_section_id_fkey" FOREIGN KEY ("section_id") REFERENCES "RiverSection"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "HatchReport" ADD CONSTRAINT "HatchReport_section_id_fkey" FOREIGN KEY ("section_id") REFERENCES "RiverSection"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CatchLog" ADD CONSTRAINT "CatchLog_section_id_fkey" FOREIGN KEY ("section_id") REFERENCES "RiverSection"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Alert" ADD CONSTRAINT "Alert_section_id_fkey" FOREIGN KEY ("section_id") REFERENCES "RiverSection"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StockingEvent" ADD CONSTRAINT "StockingEvent_section_id_fkey" FOREIGN KEY ("section_id") REFERENCES "RiverSection"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
